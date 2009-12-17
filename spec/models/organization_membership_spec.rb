require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganizationMembership do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :organization_id => 1,
      :roles => :admin
    }
  end

  it { should belong_to(:user) }
  it { should belong_to(:organization) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:organization_id) }

  it "should create a new instance given valid attributes" do
    OrganizationMembership.create!(@valid_attributes)
  end

  describe 'roles' do

    it "should support an 'admin' role" do
      membership = OrganizationMembership.create!(@valid_attributes.merge(:roles => [:admin]))
      # Note: I don't like this accessor; once bitmask-attribute 1.1.0
      # is out, we'll have something nicer. - BW
      membership.roles?(:admin).should be_true
    end
    
  end

end
