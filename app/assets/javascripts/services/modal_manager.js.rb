class Services::ModalManager
  class << self
    def instance
      @instance ||= self.new
    end
  end

  def initialize
    @active_modals_counter = 10
  end

  def active_modals_counter
    @active_modals_counter
  end

  def increment_active_modals_counter
    @active_modals_counter += 1
  end

  def decrement_active_modals_counter
    new_counter_value = @active_modals_counter - 1
    unless new_counter_value == 10
      @active_modals_counter -= 1
    end
  end

end