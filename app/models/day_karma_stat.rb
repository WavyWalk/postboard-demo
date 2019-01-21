class DayKarmaStat < ActiveRecord::Base
  belongs_to :user
  has_many :day_karma_events
end
