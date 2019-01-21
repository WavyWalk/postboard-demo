 class AsJsonSerializer < Rails::Generators::Base

  argument :class_name

  def create_serializer
    create_file "app/serializers/as_json_serializer/#{class_name.underscore}.rb", class_file_contents
  end

private
  
  def class_file_contents
    <<-FILE
class AsJsonSerializer::#{@class_name.camelize}
  
  def initialize(model = false, controller = false, options = {})
    @model = model
    @controller = controller
    @options = options
  end
  
  def success
    @model.as_json(success_options)
  end

  def error
    @model.as_json(error_options)
  end

 private

  def success_options
    {

    }
  end

  def error_options
    {

    }
  end

end
    FILE
  end

end