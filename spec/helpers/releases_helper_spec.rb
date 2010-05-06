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