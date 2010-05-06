require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do

  describe "count" do
    it "should show a count for a populated collection" do
      helper.count("thing", [1,2,3]).should have_tag('p', /3 things found/)
    end

    it "should show a disclaimer for an empty collection" do
      helper.count("thing", []).should have_tag("p", /No things found/)
    end
  end

  describe "tag_list" do
    it "should list tags" do
      name = "thing"
      taggable = mock(Mod, :tags => [Tag.new(:name => name)])
      helper.tag_list(taggable).should have_tag("a", name)
    end

    it "should list categories" do
      name = "os"
      category = Categories[name.to_sym]
      taggable = mock(Mod, :tags => [Tag.new(:name => "os")])
      helper.tag_list(taggable).should have_tag("a", category)
    end
  end

end