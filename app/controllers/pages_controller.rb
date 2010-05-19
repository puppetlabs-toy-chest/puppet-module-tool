class PagesController < ApplicationController
  def home
  end

  def root
    render :layout => false
  end
end
