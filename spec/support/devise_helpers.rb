class ActionController::TestCase
  include Devise::TestHelpers

  # Ensure the user is logged in as the specified +user+.
  def should_be_logged_in_as(user)
    controller.warden.authenticate(:scope => :user).should == user
  end

  # Ensure that the user isn't logged in.
  def should_not_be_logged_in
    controller.warden.authenticate(:scope => :user).should == nil
  end
end
