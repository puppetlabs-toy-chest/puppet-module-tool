require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ModuleLookup do

  context 'when three parts are present' do
    before do
      @lookup = ModuleLookup.new('foo-bar-baz')
    end
    it "should be true" do
      @lookup.should be_specific
    end
    describe '#sql' do
      it "should return a specific LIKE value" do
        @lookup.to_sql.should == 'foo-bar-baz'
      end
    end
  end

  context 'when two parts are present' do
    before do
      @lookup = ModuleLookup.new('foo-bar')
    end
    it "should be false" do
      @lookup.should_not be_specific
    end
    describe '#sql' do
      it "should return a glob LIKE value" do
        @lookup.to_sql.should == 'foo-bar-%'
      end
    end
  end

  context 'when one part is present' do
    before do
      @lookup = ModuleLookup.new('foo')
    end
    it "should be true" do
      @lookup.should_not be_specific
    end
    describe '#sql' do
      it "should return a specific LIKE value" do
        @lookup.to_sql.should == 'foo-%'
      end
    end

  end

end
