



        # => NOT NECESSARY
        # BEING INSTALLED THROUGH g model_validator install
        #CAN BE DELETED SAFELY
class CustomErrorableInstall < Rails::Generators::Base

  def create_custom_errorable_class
    create_file "app/service_classes/services/custom_errorable.rb", custom_errorable_class_contents
  end

private

  def custom_errorable_class_contents
    <<-'FILE'
module Services
  module CustomErrorable

    def self.included(base)
      base.validate(:check_for_custom_errors)
    end


    def custom_errors
      @custom_errors ||= Hash.new { |hash, key| hash[key] = [] }
    end

    def add_custom_error(attribute, error_message)
      self.custom_errors[attribute] << error_message
    end

    def check_for_custom_errors
      unless @custom_errors && custom_errors.empty?
        custom_errors.each do |_attribute, _errors_array|
          _errors_array.each do |error|
            self.errors.add(_attribute, error)  
          end
        end
      end  
    end

    def clear_custom_errors
      @custom_errors = Hash.new { |hash, key| hash[key] = [] }
    end  

  end
end
    FILE
  end

end