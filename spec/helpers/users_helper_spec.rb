require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersHelper do
  describe "user_link" do
    it "should return a link to the user with their user label" do
      user = Factory :user, :display_name => "Display Name", :username => "username"
      html = helper.user_link(user)
      html.should have_tag("a", "Display Name (username)")
      html.should have_tag("a[href=?]", user_path(user))
    end
  end
end
