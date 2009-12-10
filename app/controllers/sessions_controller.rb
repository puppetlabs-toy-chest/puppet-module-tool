class SessionsController < ApplicationController

  def new
  end

  def create
    if authenticate
      notify "Welcome"
      redirect_to new_session_path
    else
      notify_of :error, "Could not sign you in"
      render :action => :new
    end
  end

end
