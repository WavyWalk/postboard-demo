class DayKarmaStatsController < ApplicationController

  def index
    
    day_karma_stats = DayKarmaStat.includes(:day_karma_events).where(user_id: current_user.id)

    render json: day_karma_stats.as_json(include: [:day_karma_events])

  end

end
