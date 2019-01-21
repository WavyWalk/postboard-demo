class Waypoint

  def initialize(opt)
    @wayp = `new Waypoint(#{opt.to_n})`
  end

  def destroy
    `#{@wayp}.destroy()`
  end

end
