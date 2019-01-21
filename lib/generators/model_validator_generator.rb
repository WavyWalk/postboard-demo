class ModelValidator < Rails::Generators::Base

  argument :command_type

  def dispatch
    if command_type == 'install'
      install
    else
      create_validator(command_type)
    end
  end


private

  def install
    create_file "app/validators/model_validator/base.rb", base_class_contents
    create_file "app/validators/model_validator/custom_errorable.rb", custom_errorable_class_contents
  end

  def create_validator(model_name)
    create_file "app/validators/model_validator/#{model_name.underscore}.rb", validator_content(model_name)
  end

  def base_class_contents
    <<-'FILE'
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
  def initialize(model)
    @model = model
    @scenarios_to_validate = []
    @attributes_to_validate = []
  end

  #scenarios : *Symbol
  #method is chainable you can set attributes to chek after (or other scenarios)
  #it is assumed that your class implements certain validation scenarios like :create, :update, :check_for_foo
  #that method should follow this naming convention  - #{scenario_name_that_you_pass_in_set_scenarios}_scenario
  #in that method you either call validating methods directly or set_attributes to check for later automatic calling
  def set_scenarios(*scenarios)
    @scenarios_to_validate = scenarios
    self
  end

  #attributes : *Symbol
  #should match methods or attributes of your models for convenience (though not neccessary)
  def set_attributes(*attributes)
    @attributes_to_validate = attributes
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
    @attributes_to_validate.each do |attribute|
      @current_attribute = attribute
      self.send attribute
      @current_attribute = false
    end
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
    
    if x
      add_error(@current_attribute, error_message)
      false
    else
      true
    end
  
  end

  def should_be_longer_than(value, error_message = nil)
    
    if _x = m.send(c_a).length < value
      add_error(c_a, error_message)
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
      add_error error_message
    end

  end
  #VALIDATION METHODS
end
    FILE
  end



  def validator_content(model_name)
    
    <<-FILE
class ModelValidator::#{model_name.camelize} < ModelValidator::Base
  # def \#{attribute_name}_scenario ; def \#{attribute_name}

end

    FILE

  end

    def custom_errorable_class_contents
    <<-'FILE'
module ModelValidator
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









