require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Categories do

  before do
    @tag_name = :mytag
    @category_name = 'MyCategory'
    @category_and_tag_names = [@category_name, @tag_name]
    Categories.category(@tag_name, @category_name)
  end

  after do
    Categories.list.delete([@tag_name, @category_name])
  end

  it "should have a list of categories" do
    Categories.list.should be_a_kind_of(Array)
    Categories.list.first.should be_a_kind_of(Array)
    Categories.list.should include(@category_and_tag_names)
  end

  it "should iterate over categories with a block" do
    i = 0
    Categories.each do |category|
      i += 1
    end

    i.should be > 0
  end

  it "should add a category" do
    tag = :mytag
    category = 'MyCategory'
    Categories.list.should_receive(:<<).with([category, tag])

    Categories.category(tag, category)
  end

  it "should lookup a category by tag" do
    Categories[@tag_name].should == @category_name
  end

  it "should lookup a category by name" do
    tag = mock(Tag, :name => @tag_name, :to_sym => @tag_name)
    Categories[tag].should == @category_name
  end

  it "should return null if lookup matches nothing" do
    Categories["unknown_tag"].should be_nil
  end

end

