class DayKarmaStat < Model 
  register

  attributes :id, :user_id, :up_count, :down_count, :created_at, :updated_at
  
  has_many :day_karma_events, class_name: 'DayKarmaEvent'

  route :Index, {get: "day_karma_stats"}

end