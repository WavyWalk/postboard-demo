module Permissions
  class Exception < StandardError

    def initialize(msg = "PERMISSIONS UNATHORIZED")
      super(msg)
    end

  end
end
