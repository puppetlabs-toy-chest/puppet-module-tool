require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do

  describe "count" do
    shared_examples_for "application_helper_count_common" do
      it "should show a count of items" do
        helper.count("thing", @populated).should have_tag('p', /3 things found/)
      end

      it "should show a disclaimer if no items" do
        helper.count("thing", @unpopulated).should have_tag("p", /No things found/)
      end
    end

    describe "with collection" do
      before do
        @populated = [1,2,3]
        @unpopulated = []
      end

      it_should_behave_like "application_helper_count_common"
    end

    describe "with number" do
      before do
        @populated = 3
        @unpopulated = 0
      end

      it_should_behave_like "application_helper_count_common"
    end

    it "should fail if given invalid arguments" do
      lambda { helper.count("thing", ApplicationHelper) }.should raise_exception(TypeError)
    end
  end

  describe "tag_list" do
    it "should list tags" do
      name = "thing"
      taggable = mock(Mod, :tags => [Tag.new(:name => name)])
      helper.tag_list(taggable).should have_tag("a", name)
      helper.tag_list(taggable).should have_tag("a[href=#{tag_path(name)}]")
    end

    it "should list categories" do
      name = "os"
      category = Categories[name.to_sym]
      taggable = mock(Mod, :tags => [Tag.new(:name => "os")])
      helper.tag_list(taggable).should have_tag("a", category)
      helper.tag_list(taggable).should have_tag("a[href=#{tag_path(name)}]")
    end

    it "should list tags alphabetically" do
      foo = Tag.new(:name => "foo")
      bar = Tag.new(:name => "bar")
      baz = Tag.new(:name => "baz")
      taggable = mock(Mod, :tags => [foo, bar, baz])

      response.body = helper.tag_list(taggable)
      
      elements = assert_select("a")
      elements.map{|element| element.attributes['href']}.should == [
        tag_path("bar"),
        tag_path("baz"),
        tag_path("foo")
      ]
    end
  end

  describe "privilege_label" do
    it "should be '(DEV)' if in dev mode" do
      helper.stub!(:privileged? => :dev)
      helper.privilege_label.should == "(DEV)"
    end

    it "should be '(ADMIN') if in admin mode" do
      helper.stub!(:privileged? => :admin)
      helper.privilege_label.should == "(ADMIN)"
    end

    it "should be nil otherwise" do
      helper.stub!(:privileged? => false)
      helper.privilege_label.should be_nil
    end
  end

end
