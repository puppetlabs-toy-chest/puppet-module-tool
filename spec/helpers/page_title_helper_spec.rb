require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PageTitleHelper do

  before :each do
    helper.instance_eval do
      @_page_title = nil
    end
  end

  it "should set and get a specific page title" do
    title = "mytitle"

    helper.page_title(title)

    helper.page_title.should == title
  end

  it "should get a default page title" do
    @controller.stub!(:controller_name => "pages", :action_name => "show")

    helper.page_title.should == "Pages: Show"
  end

end
