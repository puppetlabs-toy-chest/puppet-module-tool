module UsersHelper

  def viewing_own?
    @user == current_user
  end
  
end
