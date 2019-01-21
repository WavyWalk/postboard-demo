class DayKarmaEvent < ActiveRecord::Base

  belongs_to :day_karma_stat
  belongs_to :source, polymorphic: true
  belongs_to :user

end
