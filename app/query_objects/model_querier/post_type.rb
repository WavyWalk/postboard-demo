class ModelQuerier::PostType

  def initialize(qo = ::PostType)
    @qo = qo
  end

  def get_all_types
    @qo = @qo.all
  end

end
