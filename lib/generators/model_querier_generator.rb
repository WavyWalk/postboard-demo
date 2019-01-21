 class ModelQuerier < Rails::Generators::Base

  argument :class_name

  def create_serializer
    create_file "app/query_objects/model_querier/#{class_name.underscore}.rb", class_file_contents
  end

private

  def class_file_contents
    <<-FILE
class ModelQuerier::#{@class_name.camelize}

  def initialize(qo = false)
    @qo = qo
  end

end
    FILE
  end

end
