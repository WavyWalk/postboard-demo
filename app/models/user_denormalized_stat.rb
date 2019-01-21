class UserDenormalizedStat < ActiveRecord::Base

  belongs_to :user

  def updater_service
    Services::UserDenormalizedStat::Updater.new(self)
  end

end
