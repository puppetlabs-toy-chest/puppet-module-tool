class PagesController < ApplicationController
  def home
    redirect_to root_path
  end

  def root
    page_title "Home"
  end
end
