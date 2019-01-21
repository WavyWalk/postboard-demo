%x{
  window.callOauthProcSetBeforePopupOpen = function(){
    #{OauthHelper.call_on_auth_proc}
  }
}

class OauthHelper

  DEFAULT_PROC = ->{raise "#{self}.name @@on_auth_proc was not set before opening provider window"}

  @@on_auth_proc = DEFAULT_PROC

  def self.set_proc_on_auth_popup_close(&block)
    @@on_auth_proc = block
  end

  def self.call_on_auth_proc
    @@on_auth_proc.call()
  end

  def self.flush
    @@on_auth_proc = DEFAULT_PROC
  end

  def self.open_child_window(path)
    %x{
        var left = (screen.width / 2) - (screen.width / 2);
        var top = (screen.height / 2) - (screen.width / 2);
        var width = (screen.width / 2);
        var height = (screen.height / 2);

        return window.open(
          #{path}, 
          'oauth', 
          #{"menubar=no,toolbar=no,status=no,width=#{`width`},height=#{`height`},left=#{`left`},top=#{`top`}"}
        );
    }
  end

end
