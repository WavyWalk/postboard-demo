class SelectOption

  attr_accessor :select_value, :show_value

  def initialize(select_value, show_value = false)
    @select_value = select_value
    @show_value = show_value ? show_value : select_value
  end

end
