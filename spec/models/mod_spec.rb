require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mod do

  before(:each) do
    @valid_attributes = {
      :name => "foo"
    }
  end

  describe "checking uniqueness" do
    before do
      # The matcher needs an existing record
      Factory.create(:mod)
    end
    it { should validate_uniqueness_of(:name).scoped_to([:owner_id, :owner_type]) }
  end

  it { should validate_format_of(:name).with('foo') }
  it { should validate_format_of(:name).not_with('bad_char').with_message(/alphanumeric/) }
  it { should validate_format_of(:name).not_with('1').with_message(/2 or more/) }

  it { should validate_format_of(:source).not_with('foo').with_message(/location invalid/) }
  it { should validate_format_of(:source).not_with('foo.com').with_message(/location invalid/) }
  # TODO: support these using a public key, eventually
  it { should validate_format_of(:source).not_with('git@github.com:bar/foo').with_message(/location invalid/) }
  it { should validate_format_of(:source).not_with('git@github.com:bar/foo.git').with_message(/location invalid/) }

  it { should validate_format_of(:source).with('git://github.com/bar/foo.git') }
  it { should validate_format_of(:source).with('http://github.com/bar/foo.git') } 
  it { should validate_format_of(:source).with('https://github.com/bar/foo.git') }
    
end
