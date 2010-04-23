require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ModsHelper do

  describe "project_link_feed" do
    it "should return an ATOM feed" do
      mod = Factory(:mod, :project_feed_url => "http://foo.bar/feed.atom")

      helper.project_feed_link(mod).should =~ /<link.+atom\+xml/
    end

    it "should return a RSS feed" do
      mod = Factory(:mod, :project_feed_url => "http://foo.bar/feed.rss")

      helper.project_feed_link(mod).should =~ /<link.+rss\+xml/
    end

    it "should return nothing for an unknown feed" do
      mod = Factory(:mod, :project_feed_url => "http://foo.bar/feed.wtf")

      helper.project_feed_link(mod).should == nil
    end

    it "should return nothing if no feed" do
      mod = Factory(:mod, :project_feed_url => nil)

      helper.project_feed_link(mod).should == nil
    end
  end

end
