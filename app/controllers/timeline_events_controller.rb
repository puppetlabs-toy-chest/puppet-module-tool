class TimelineEventsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_user
  
  def index
    @timeline = scope.timeline.paginate(:page => params[:page],
                                        :order => 'created_at desc')
  end

  private
  
  def find_user
    if params[:user_id]
      @user = User.find_by_username(params[:user_id])
    end
  end

  def scope
    TimelineScope.new(params)
  end

  class TimelineScope
    def initialize(params)
      @name = params[:scope] || 'watched'
    end

    
  end

end
