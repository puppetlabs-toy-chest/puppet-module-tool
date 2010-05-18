require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReleasesHelper do

  describe "guess_next_version" do
    it "should return a version if a release is available" do
      mod = Factory :mod
      release1 = Factory :release, :mod => mod, :version => '0.4.2'
      release2 = Factory.build :release, :mod => mod
      assigns[:mod] = mod
      assigns[:release] = release2

      helper.guess_next_version.should == '0.4.3'
    end

    it "should return nil if no release is available" do
      mod = Factory :mod
      release = Factory.build :release, :mod => mod
      assigns[:mod] = mod
      assigns[:release] = release

      helper.guess_next_version.should be_nil
    end
  end

  describe "label_doc" do
    it "should return the name if present" do
      helper.label_doc(:name => "MyName").should have_tag("b", "MyName")
    end

    it "should return the documentation if present" do
      helper.label_doc(:doc => "*MyDoc*").should have_tag("em", "MyDoc")
    end

    it "should return the name and documentation if present" do
      result = helper.label_doc(:name => "MyName", :doc => "*MyDoc*")
      result.should have_tag("b", /MyName:/)
      result.should have_tag("em", "MyDoc")
    end

    it "should return nothing if no name or documentation" do
      helper.label_doc(:invalid_key => "Invalid value").should be_blank
    end

    it "should return nothing if called with non-Hash argument" do
      helper.label_doc(:invalid_argument).should be_blank
    end
  end

  describe "link_to_dependency" do
    it "should link to a named item" do
      helper.link_to_dependency("name" => "thingy").should have_tag("a", "thingy")
    end

    it "should not link to an unnamed item" do
      helper.link_to_dependency("foo" => "bar").should be_nil
    end
    
    it "should not link to a non-hash" do
      helper.link_to_dependency(mock(Mod)).should be_nil
    end
  end

end

