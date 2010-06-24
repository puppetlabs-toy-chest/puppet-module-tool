require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TagsController do
  describe "show" do
    before do
      @tag = "tag"
      @mod_with_tag = Factory :mod, :tag_list => @tag

      @another_tag = "another_tag"
      @mod_with_another_tag = Factory :mod, :tag_list => @another_tag

      @category = "os"
      @category_text = Categories[@category]
      @mod_with_category = Factory :mod, :tag_list => @category
    end

    shared_examples_for "tags_controller_show_common" do
      it "should show a tag and its mods" do
        get :show, :format => @format, :id => @tag

        response.should be_success
        assigns[:mods].should == [@mod_with_tag]
        assigns[:category].should be_nil
      end

      it "should show a category and its mods" do
        get :show, :format => @format, :id => @category

        response.should be_success
        assigns[:mods].should == [@mod_with_category]
        assigns[:category].should == @category_text
      end

      it "should redirect if given an invalid tag" do
        get :show, :format => @format, :id => "Invalid Tag"

        response_should_be_not_found
      end
    end

    describe "as HTML" do
      before do
        @format = "html"
      end

      it_should_behave_like "tags_controller_show_common"
    end

    describe "as JSON" do
      before do
        @format = "json"
      end

      it_should_behave_like "tags_controller_show_common"
    end

  end
end