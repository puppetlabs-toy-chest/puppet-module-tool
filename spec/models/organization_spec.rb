require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organization do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :title => "value for title",
      :description => "value for description"
    }
  end

  it { should have_many(:namespaces) }
  
  it "should create a new instance given valid attributes" do
    Organization.create!(@valid_attributes)
  end
end
