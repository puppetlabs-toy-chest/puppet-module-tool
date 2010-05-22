module UsersHelper
  def user_link(user)
    return link_to(h(user.label), user_path(user))
  end
end
