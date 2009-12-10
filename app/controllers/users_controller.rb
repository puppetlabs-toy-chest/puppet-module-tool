class UsersController < ApplicationController

  before_filter :require_user
  
  def show
  end

end
