#Model should include CustomErrorble module
#the idea is:
# validation rules clutter models and are hard to manage when you have many condionals
# this way you can set validation scenarios and run against them which is more cleaner and helps with decoupling

# this works as follows
#   you instantiate this
#   implement your validation rules
#   set scenarios and or attributes to validate and run
#   if there's error you just record it in on model through custom errorable, and thanks to it then model will validate as regular
#   and if any
#   custom_errors where set, they will be copied to real model's errors for you to handle them later as usual

class ModelValidator::Base

  #model : ActiveRecord wich has included CustomErrorable module
  def initialize(model, options = {})
    @model = model
    @scenarios_to_validate = []
    @attributes_to_validate = []
    @options = options
  end

  #scenarios : *Symbol
  #method is chainable you can set attributes to chek after (or other scenarios)
  #it is assumed that your class implements certain validation scenarios like :create, :update, :check_for_foo
  #that method should follow this naming convention  - #{scenario_name_that_you_pass_in_set_scenarios}_scenario
  #in that method you either call validating methods directly or set_attributes to check for later automatic calling
  def set_scenarios(*scenarios)
    @scenarios_to_validate += scenarios
    self
  end



  #attributes : *Symbol
  #should match methods or attributes of your models for convenience (though not neccessary)
  def set_attributes(*attributes)
    @attributes_to_validate += attributes
    self
  end

# Example
#   you implement for example 2 schenarios
#   def create_scenario
#       set_attributes :name, :password
#       #you can simply call directly (like: name() ; password() ) but you better set them this way
#       #because it will give some convinience later
#   end

#   def update_scenario #your :update scenario that you passed to set_scenario
#     set_attributes :name
#   end

#   there you are setting attributes that will be checked (attributes just mimick names of attributes of models).
#   your validation then should have such methods - name and password where your validation logic will sit
#   def name
#     if name.length < 4
#       add_error :name, "too short"
#     end
#   end

#   def password
#     if password == nil
#       add_error :password, "not provided"
#     end
#   end

#   than somewhere (e.g. in ComposerFor) you just do UserValidator.new(@user).set_scenarios(:create).validate
#     *why better to set in scenarios methods to check through set attributes

#   if in your scenarios (inside #{name}_scenario methods) you set via set_attributes(:foo, :bar) (or you where calling
#   set_attributes on validator directly before #validate)
#   when you will call validate all those methods will be called, and while such method will run @current_attribute will be assigned to such method
#   name. this way you can implement generic validation check methods without passing atribute easily on Base class for later usage and
#   dryness e.g.

#   def should_match_confirmation(error_message = "should match confirmation")
#     if m.send(c_a) != m.send("#{c_a}_confirmation")
#       add_error(c_a, error_message)
#     end
#   end

#   wich will allow beatifull implementations like

#   def name
#     should_be_cool unless is_blank?
#     should_match_confirmation and should_be_strong
#      # and etc without passing args
#   end
# set_scenarios and set_attributes are chainable e.g. MyValidator.new(@user).set_scenarios(:update, :promote).set_attributes(:status).validate

  def validate

    @scenarios_to_validate.each do |scenario|
      self.send "#{scenario}_scenario"
    end

    @attributes_to_validate.uniq!

    @attributes_to_validate.each do |attribute|
      @current_attribute = attribute
      self.send attribute
      @current_attribute = false
    end

  end


  def validate_and_propagate_errors_to_model
    validate
    @model.validate
  end


  #MODEL SHOUL INCLUDE CustomErrorable or implement #add_error your way
  def add_error(attribute, error_message)
    @model.add_custom_error(attribute, error_message)
  end

  #SHORTHANDS
  def c_a
    @current_attribute
  end

  def m
    @model
  end

private
  #VALIDATION METHODS
  #INCLUDE YOURS HERE
  #methods better return either true or false depending on errors
  #for conditional chaining e.g. should_present and should_be_uniq and should_be_awesome.
  #so if one fails others wont run
  def should_be_uniq(error_message = "is not uniq")

    x = @model.class.where(@current_attribute => @model.send(@current_attribute)).first

    if x && @model.id != x.id 
      add_error(@current_attribute, error_message)
      false
    else
      true
    end

  end


  def should_be_longer_than(value, error_message = nil)

    error_message = error_message ? error_message : "must have at least #{value} letters"

    unless _x = m.send(c_a).length > value
      add_error(c_a, error_message)
      return false
    else
      return true
    end

  end

  def not_blank?

    if m.send(c_a).blank?
      false
    else
      true
    end

  end

  def should_match_confirmation(error_message = "should match confirmation")

    if m.send(c_a) != m.send("#{c_a}_confirmation")
      add_error(c_a, error_message)
    end

  end

  def should_be_valid_email(error_message = "not valid email")
    #this sucks i know this is more of an example
    unless m.send(c_a).include?('@') && m.send(c_a).include?('.')
      add_error c_a, error_message
    end
  end

  def should_present(error_message = "should be assigned")

    unless not_blank?
      add_error c_a, error_message
      return false
    else
      return true
    end

  end

  def should_be_signed_integer(error_message = "incorrect amount")

    unless m.send(c_a).is_a?(Integer)
      add_error c_a, error_message
    end

  end

  def should_be_numeric_string(error_message = "should be numeric string")

    value_to_test = m.send(c_a)


    final_value_to_test =  value_to_test.gsub(',', '')
    matches = final_value_to_test.match(/-?\d+(?:\.\d+)?/)
    if !matches.nil? && matches.size == 1 && matches[0] == final_value_to_test
      true
    else
      add_error c_a, error_message
    end

  end



  def should_regex_match_one_of(arr, message = 'invalid')
    
    matched = false
    test_value = m.send(c_a) || ""
    
    arr.each do |regex|
      if test_value.match(regex)
        matched = true
      end
    end

    if matched
      true
    else
      add_error c_a, message
    end

  end



  def should_not_be_zero(error_message = "should not be zero")
    test_value = m.send(c_a)
    if test_value == 0
      add_error c_a, error_message
    end
  end

  def other_attr_presents?(attr)
    test_value = m.send(attr)
    if test_value.blank?
      return false
    else
      return true
    end
  end

  def should_not_contain_symbols(error_message = 'contains illegal characters')
    test_value = m.send(c_a)
    match = test_value.match(/^[A-Za-zа-яА-Я0-9 ]+$/)

    unless match
      add_error c_a, error_message
    end
  end

  def should_not_be_in(target_array:, error_message: 'reserved')

    test_value = m.send(c_a)

    if target_array.include?(test_value)
      add_error c_a, error_message
    end

  end

  def should_be_in(target_array:, error_message: 'invalid')
    
    test_value = m.send(c_a)

    if target_array.include?(test_value)
      true
    else
      add_error c_a, error_message
    end

  end

  def should_not_be_empty(error_message: "required property is empty")
    test_value = m.send(c_a)
    if test_value.empty?
      add_error c_a, error_message
    end
  end

  def should_eq_true(error_message: 'should be true')
    test_value = m.send(c_a)

    if test_value != true
      add_error c_a, error_message
    end
  end


  #VALIDATION METHODS
end
