class PagesController < ApplicationController
  before_filter :redirect_users, :only => :home

  private

  def redirect_users
    if current_user
      redirect_to user_path(current_user)
    end
  end
  
end
