class CreatePermissionRules < Rails::Generators::Base

  argument :class_name

  def create_permission_rules
    create_file "app/permission_system/permissions/#{class_name.underscore}_rules.rb", class_file_contents
  end

private
  
  def class_file_contents
    <<-FILE
class Permissions::#{@class_name.camelize}Rules < Permissions::Base

end
    FILE
  end

end