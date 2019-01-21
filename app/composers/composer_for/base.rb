class ComposerFor::Base

  #inheriting class should implement
  #resolve_fail(exception_or_string_message); #resolve_success; #compose
  #compose shall be treated as transactional

  #depends on Services::PubSubBus::Publisher

  include Services::PubSubBus::Publisher

  #inheriting should implement this method and it is used to dispatch preparation methods like e.g.
  #attributes assignment, validation, attr permission and etc
  #!IT WILL RUN AUTOAMTICALLY after init
  #use this to prepare your instance vars and etc.
  def before_compose

  end

  #this methods are handy if you need to check if composer is done it's job
  #e.g. ensure in controller that composer.is_done?
  def is_done?
    !!@done
  end

  #refer to #is_done?
  def set_done
    @done = true
  end

  #should be used in #compose, it raises and causes rollback
  #accepts reason : String | Symbol (or even your custom exceptions) for later usage in
  # #resolve_fail
  # example:
  #    in compose
  # def compose
  #   fail_immediately(:unauthorized) if unauthorized?
  # end
  # in resolve
  # def resolve_fail(e)
  #   when e
  #   case :unauthorized
  #     publish(:unauthorized) #or @controller.head 403
  #   end
  # end
  #
  def fail_immediately(reason)
    @failed = true
    fail_reasons << reason
    raise 'immediate_fail'
  end

  #DOES not raise but logs to fail reasons
  #then before resolution this will be cheked and if this was called
  # it will raise, causing rollback later before final check
  # in #resolve_fail you can chek if e == :multiple_failures, and access the fail_reason array
  # eg. in resolve fail
  #   case e
  #   when :multiple_failures
  #     fail_reasons.include? :foo
  #     publish(:foo)
  #   end
  #Handy if you save multiple models for example and only some of them will raise something,
  #this way you can understand and grab the ones you need.
  def record_fail_and_continue(reason)
    @failed = true
    fail_reasons << reason
  end

  #flags failed.
  # @failed is set from #fail_immediately and #record_fail_and_continue
  # it is checked to either resolve success or fail if no prior raises were made
  def failed?
    @failed ||= false
  end
  #refer to #failed?
  def failed=(value)
    @failed = value
  end

  #fail resons contains messages that you set in #fail_immediately(message) or in #record_fail_and_continue(message)
  #then you can access them in resolve_fail
  def fail_reasons
    @fail_reasons ||= []
  end

  #runs your composer
  #compose method is wrapped in transaction, all database interaction should occur there
  #in compose you should not resolve directly (e.g. publish :success) it is assumed that if
  #nothing got raised your compose is success and composer can publish that all is ok autmatically
  #in #resolve_success; otherwise resolve_fail will be called
  #TODO: FIXME: #if something raises in block in publish, considered as failed
  #and it should not.
  #example: somecmpsr calls this cmpsr, this cmpsr os ok, somecmpsr raises and this cmpsr thinks that
  #this raise is his. fuck.
  #probably fixed BUT needs checking
  def run
    begin
      before_compose
      #You can optionally set it in initilizer or before compose for #compose to be run without transaction
      if @compose_without_transaction
        compose
      else
        ActiveRecord::Base.transaction do
          compose
        end
      end

      after_compose

      check_if_was_set_as_failed_by_user

    rescue Exception => e
      if e.message == 'immediate_fail'
        e = fail_reasons.first
      elsif e.message == 'failed_on_check'
        e = :multiple_failures
      end

      resolve_fail(e)
      return
    end

    resolve_success

  end

  def after_compose

  end

  def check_if_was_set_as_failed_by_user
    if failed?
      raise 'failed_on_check'
    end
  end

  def resolve_success
    raise "#{self.class.name} #resolve success not implemented"
  end

  def resolve_fail(e)
    raise "#{self.class.name} #resolve_fail not implemented"
    #example implementation
    # case e
    # when ActiveRecord::RecordInvalid
    #   publish(:validation_error, @model)
    # else
    #   raise e
    # end
  end

end
