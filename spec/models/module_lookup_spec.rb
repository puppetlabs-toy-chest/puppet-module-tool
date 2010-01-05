require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ModuleLookup do

  describe '#ready?' do

    context 'when an organization_id is set' do
      before do
        @lookup = ModuleLookup.new(:organization_id => 1)
      end
      it "should be true" do
        @lookup.should be_ready
      end
    end

    context 'when a user_id is set' do
      before do
        @lookup = ModuleLookup.new(:user_id => 1)
      end
      it "should be true" do
        @lookup.should be_ready
      end
    end

    context 'when an organization_id and user_id are set' do
      before do
        @lookup = ModuleLookup.new(:organization_id => 1, :user_id => 2)
      end
      it "should be true" do
        @lookup.should be_ready
      end
    end

    context 'when neither organization_id and user_id are set' do
      before do
        @lookup = ModuleLookup.new({})
      end
      it "should be false" do
        @lookup.should_not be_ready
      end
    end


  end


end
