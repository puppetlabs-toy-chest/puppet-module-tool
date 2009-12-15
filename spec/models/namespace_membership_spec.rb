require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NamespaceMembership do
  before(:each) do
    @valid_attributes = {
      :namespace_id => 1,
      :user_id => 1
    }
  end

  it { should belong_to(:user) }
  it { should belong_to(:namespace) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:namespace_id) }

  it "should create a new instance given valid attributes" do
    NamespaceMembership.create!(@valid_attributes)
  end

  describe 'roles' do

    it "should support an 'admin' role" do
      membership = NamespaceMembership.create!(@valid_attributes.merge(:roles => [:admin]))
      # Note: I don't like this accessor; once bitmask-attribute 1.1.0
      # is out, we'll have something nicer. - BW
      membership.should be_roles_for_admin
    end
    
  end
  
end
