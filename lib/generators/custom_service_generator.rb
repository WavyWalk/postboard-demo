 class CustomService < Rails::Generators::Base

  argument :class_name

  def create_serializer
    create_file "app/service_classes/services/#{class_name.underscore}.rb", class_file_contents
  end

private
  
  def class_file_contents
    <<-FILE
class Services::#{@class_name.camelize}
  
  
  
end
    FILE
  end

end