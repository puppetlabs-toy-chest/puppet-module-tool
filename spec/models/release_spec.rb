require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Release do
  describe "to_param" do
    it "should be the version" do
      release = Factory :release

      release.to_param.should == release.version
    end
  end

  describe "guess_next_version" do
    it "should fail if there's no version" do
      release = Factory.build :release, :version => nil

      lambda { release.guess_next_version }.should raise_error(ArgumentError)
    end

    it "should guess first tiny version" do
      release = Factory.build :release, :version => '0.1'

      release.guess_next_version.to_s.should == '0.1.1'
    end

    it "should guess next tiny version" do
      release = Factory.build :release, :version => '0.0.1'

      release.guess_next_version.to_s.should == '0.0.2'
    end
  end

  describe "metadata" do
    it "should return metadata if available" do
      metadata = {:meta => :data}
      release = Factory.build :release, :metadata => metadata

      release.metadata.should == metadata
    end

    it "should return empty hash if not available" do
      release = Factory.build :release, :metadata => nil

      release.metadata.should == {}
    end
  end

  describe "validate_version" do
    it "should pass if the version parses" do
      release = Factory.build :release, :version => '0.0.1'
      release.validate_version

      release.errors.should be_empty
    end

    it "should fail if the version doesn't parse" do
      release = Factory.build :release, :version => 'asdf'
      release.validate_version

      release.errors.should_not be_empty
      release.errors.on(:version).should_not be_blank
    end

    it "should fail if there's no version" do
      release = Factory.build :release, :version => nil
      release.validate_version

      release.errors.should_not be_empty
      release.errors.on(:version).should_not be_blank
    end
  end

  describe "validate_mod" do
    it "should pass if there's a mod" do
      release = Factory.build :release
      release.validate_mod

      release.errors.should be_empty
    end

    it "should fail if there's no mod" do
      release = Factory.build :release, :mod => nil
      release.validate_mod

      release.errors.should_not be_empty
      release.errors.on(:base).should =~ /module/
    end
  end

  describe "validate_file" do
    it "should pass if there's a file" do
      release = Factory :release, :file => "mymodule-0.0.1.tar.gz"
      release.validate_file

      release.errors.should be_empty
    end

    it "should fail if there's no file" do
      release = Factory.build :release, :file => nil
      release.validate_file

      release.errors.should_not be_empty
      release.errors.on(:file).should =~ /must be provided/
    end
  end

  describe "extract_metadata" do
    describe "valid file" do
      before do
        @release = Factory :release, :file => "mymodule-0.0.1.tar.gz"
        @metadata = @release.metadata
      end

      it "should have metadata" do
        @metadata.should_not be_blank
      end

      it "should have a name" do
        @metadata['name'].should == "mymodule"
      end

      it "should have a version" do
        @metadata['version'].should == '0.0.1'
      end

      it "should have checksums" do
        @metadata['checksums']['lib/puppet/type/README.markdown'].should == "962259712efcf0b409ff3358b51fca3b"
      end

    end

    it "should fail with invalid metadata from valid archive"
    it "should fail with missing metadata from valid archive"
    it "should fail with invalid archive"
    it "should fail with missing archive"
  end
end
