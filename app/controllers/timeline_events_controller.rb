class TimelineEventsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_user
  
  def index
    # TODO Implement the +scope+ object.
    # @timeline = scope.timeline.paginate(:page => params[:page], :order => 'created_at desc')
    @timeline = []
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
