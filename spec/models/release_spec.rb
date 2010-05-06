require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Release do
  describe "to_param" do
    it "should be the version" do
      release = Factory :release

      release.to_param.should == release.version
    end
  end

  describe "guess_next_version" do
    it "should guess initial version"
    it "should guess minor version"
    it "should guess tiny version"
  end

  describe "metadata" do
    it "should return metadata if available"
    it "should return empty hash if not available"
  end

  describe "validate_version" do
    it "should pass if the version parses"
    it "should fail if the version doesn't parse"
    it "should fail if there's no version"
  end

  describe "validate_mod" do
    it "should pass if there's a mod"
    it "should fail if there's no mod"
  end

  describe "validate_file" do
    it "should pass if there's a file"
    it "should fail if there's no file"
  end
end