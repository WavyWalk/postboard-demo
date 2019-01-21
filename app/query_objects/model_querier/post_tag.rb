class ModelQuerier::PostTag

  def initialize(model = ::PostTag)
    @relation = model.all
  end

  def where_name_like(name)
    @relation.where("name like ?", "%#{name}%")
  end

end