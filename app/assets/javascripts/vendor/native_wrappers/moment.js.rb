class Moment

  def self.new(*opt)
    if opt.empty?
      @native = Native(`moment()`)
    else
      @native = Native(`moment.apply(null, #{opt})`)
    end
  end

end