class ModelQuerier::PostImage

  def initialize(qo = PostImage)
    @qo = qo
  end

  def find_first_by_id(id)
    @qo = @qo.where(id: id).first
    self
  end

  def get_result
    @qo
  end

end
