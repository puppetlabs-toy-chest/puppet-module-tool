require 'spec_helper'
require 'tmpdir'

# Directory that contains sample releases.
RELEASE_FIXTURES_DIR = File.join(File.dirname(File.expand_path(__FILE__)), "..", "fixtures", "releases")

# Return the pathname string to the directory containing the release fixture called +name+.
def release_fixture(name)
  return File.join(RELEASE_FIXTURES_DIR, name)
end

# Copy the release fixture called +name+ into the current working directory.
def install_release_fixture(name)
  release_fixture(name)
  FileUtils.cp_r(release_fixture(name), name)
end

describe "cli" do
  before do
    @mytmpdir = Pathname.new(Dir.mktmpdir)
    Puppet::Module::Tool.stubs(:install_dir).returns(@mytmpdir)
  end

  def build_and_install_module
    app.generate(@full_name)
    app.build(@full_name)

    FileUtils.mv("#{@full_name}/pkg/#{@release_name}.tar.gz", "#{@release_name}.tar.gz")
    FileUtils.rm_rf(@full_name)

    app.install("#{@release_name}.tar.gz")
  end

  # Return STDOUT and STDERR output generated from +block+ as it's run within a temporary test directory.
  def run(&block)
    return output_for do
      mktestdircd do
        block.call
      end
    end
  end

  def app
    return Puppet::Module::Tool::CLI.new
  end

  before :all do
    Puppet::Module::Tool.prepare_settings

    @username = "myuser"
    @module_name  = "mymodule"
    @full_name = "#{@username}-#{@module_name}"
    @version = "0.0.1"
    @release_name = "#{@full_name}-#{@version}"
  end

  before :each do
    Puppet::Module::Tool::Cache.clean
  end

  after :each do
    Puppet::Module::Tool::Cache.clean
  end

  describe "version" do
    it "should display a version" do
      run do
        app.version
      end.should =~ /#{Puppet::Module::Tool.version}/
    end
  end

  describe "generate" do
    it "should generate a module if given a dashed name" do
      run do
        app.generate(@full_name)

        File.directory?(@full_name).should == true
        modulefile = File.join(@full_name, "Modulefile")
        File.file?(modulefile).should == true
        metadata = Puppet::Module::Tool::Metadata.new
        Puppet::Module::Tool::Modulefile.evaluate(metadata, modulefile)
        metadata.full_name.should == @full_name
        metadata.username.should == @username
        metadata.name.should == @module_name
      end.should =~ /Generating module/
    end

    it "should fail if given an undashed name" do
      run do
        lambda { app.generate("invalid") }.should raise_error(SystemExit)
      end.should =~ /Could not generate directory "invalid", you must specify a dash-separated username and module name./
    end

    it "should fail if directory already exists" do
      run do
        app.generate(@full_name)
        lambda { app.generate(@full_name) }.should raise_error(SystemExit)
      end.should =~ /already exists/
    end
  end

  describe "build" do
    it "should build a module in a directory" do
      run do
        app.generate(@full_name)
        app.build(@full_name)

        File.directory?(File.join(@full_name, "pkg", @release_name)).should == true
        File.file?(File.join(@full_name, "pkg", @release_name + ".tar.gz")).should == true
        metadata_file = File.join(@full_name, "pkg", @release_name, "metadata.json")
        File.file?(metadata_file).should == true
        metadata = PSON.parse(File.read(metadata_file))
        metadata["name"].should == @full_name
        metadata["version"].should == @version
        metadata["checksums"].should be_a_kind_of(Hash)
        metadata["dependencies"].should == []
        metadata["types"].should == []
      end.should =~ /Building.+Built/m
    end

    it "should build a module's checksums" do
      run do
        app.generate(@full_name)
        app.build(@full_name)

        metadata_file = File.join(@full_name, "pkg", @release_name, "metadata.json")
        metadata = PSON.parse(File.read(metadata_file))
        metadata["checksums"].should be_a_kind_of(Hash)

        modulefile_path = Pathname.new(File.join(@full_name, "Modulefile"))
        metadata["checksums"]["Modulefile"].should == Digest::MD5.hexdigest(modulefile_path.read)
      end
    end

    it "should build a module's types and providers" do
      run do
        name = "jamtur01-apache"
        install_release_fixture name
        app.build(name)

        metadata_file = File.join(name, "pkg", "#{name}-0.0.1", "metadata.json")
        metadata = PSON.parse(File.read(metadata_file))

        metadata["types"].size.should == 1
        type = metadata["types"].first
        type["name"].should == "a2mod"
        type["doc"].should == "Manage Apache 2 modules"


        type["parameters"].size.should == 1
        type["parameters"].first.tap do |o|
          o["name"].should == "name"
          o["doc"].should == "The name of the module to be managed"
        end

        type["properties"].size.should == 1
        type["properties"].first.tap do |o|
          o["name"].should == "ensure"
          o["doc"].should =~ /present.+absent/
        end

        type["providers"].size.should == 1
        type["providers"].first.tap do |o|
          o["name"].should == "debian"
          o["doc"].should =~ /Manage Apache 2 modules on Debian-like OSes/
        end
      end
    end

    it "should build a module's dependencies" do
      run do
        app.generate(@full_name)
        modulefile = File.join(@full_name, "Modulefile")

        dependency1_name = "anotheruser-anothermodule"
        dependency1_requirement = ">= 1.2.3"
        dependency2_name = "someuser-somemodule"
        dependency2_requirement = "4.2"
        dependency2_repository = "http://some.repo"

        File.open(modulefile, "a") do |handle|
          handle.puts "dependency '#{dependency1_name}', '#{dependency1_requirement}'"
          handle.puts "dependency '#{dependency2_name}', '#{dependency2_requirement}', '#{dependency2_repository}'"
        end

        app.build(@full_name)

        metadata_file = File.join(@full_name, "pkg", "#{@full_name}-#{@version}", "metadata.json")
        metadata = PSON.parse(File.read(metadata_file))

        metadata['dependencies'].size.should == 2
        metadata['dependencies'].sort_by{|t| t['name']}.tap do |dependencies|
          dependencies[0].tap do |dependency1|
            dependency1['name'].should == dependency1_name
            dependency1['version_requirement'].should == dependency1_requirement
            dependency1['repository'].should be_nil
          end

          dependencies[1].tap do |dependency2|
            dependency2['name'].should == dependency2_name
            dependency2['version_requirement'].should == dependency2_requirement
            dependency2['repository'].should == dependency2_repository
          end
        end
      end
    end


    it "should rebuild a module in a directory" do
      run do
        app.generate(@full_name)
        app.build(@full_name)
        app.build(@full_name)
      end.should =~ /Building.+Built.+Building.+Built/m
    end

    it "should build a module in the current directory" do
      run do
        app.generate(@full_name)
        Dir.chdir(@full_name)
        app.build

        File.file?(File.join("pkg", @release_name + ".tar.gz")).should == true
      end.should =~ /Building.+Built/m
    end

    it "should fail to build a module without a Modulefile" do
      run do
        app.generate(@full_name)
        FileUtils.rm(File.join(@full_name, "Modulefile"))

        lambda { app.build(@full_name) }.should raise_error(SystemExit)
      end.should =~ /Could not find a valid module at "#{@full_name}"/
    end

    it "should fail to build a module directory that doesn't exist" do
      run do
        lambda { app.build(@full_name) }.should raise_error(SystemExit)
      end.should =~ /Could not find a valid module at "#{@full_name}"/
    end

    it "should fail to build a module in the current directory that's not a module" do
      run do
        lambda { app.build }.should raise_error(SystemExit)
      end.should =~ /Could not find a valid module at current directory/
    end
  end

  describe "search" do
    it "should display matching modules" do
      run do
        stub_repository_read 200, <<-HERE
          [
            {"full_name": "cli", "version": "1.0"},
            {"full_name": "web", "version": "2.0"}
          ]
        HERE
        app.search("mymodule")
      end.should =~ /2 found.+cli.+1\.0.+web.+2\.0/m
    end

    it "should display no matches" do
      run do
        stub_repository_read 200, "[]"
        app.search("mymodule")
      end.should =~ /0 found/m
    end

    it "should fail if can't get a connection" do
      run do
        stub_repository_read 500, "OH NOES!!1!"
        app.search("mymodule")
      end.should =~ /Could not execute search.+HTTP 500/m
    end
  end

  describe "install" do
    it "should install a module to the puppet modulepath by default" do
      myothertmpdir = Pathname.new(Dir.mktmpdir)
      run do
        Puppet.settings[:puppet_module_install_dir] = myothertmpdir
        Puppet::Module::Tool.unstub(:install_dir)

        build_and_install_module

        File.directory?(myothertmpdir + @module_name).should == true
        File.file?(myothertmpdir + @module_name + 'metadata.json').should == true
      end.should =~ /Installed "myuser-mymodule-0.0.1" into directory: #{Regexp.escape(myothertmpdir + @module_name)}/
    end

    it "should install a module from a filesystem path" do
      run do
        build_and_install_module

        File.directory?(@mytmpdir + @module_name).should == true
        File.file?(@mytmpdir + @module_name + 'metadata.json').should == true
      end.should =~ /Installed "myuser-mymodule-0.0.1" into directory: #{Regexp.escape(@mytmpdir + @module_name)}/
    end

    it "should install a module from a webserver URL" do
      run do
        app.generate(@full_name)
        app.build(@full_name)

        stub_cache_read File.read("#{@full_name}/pkg/#{@release_name}.tar.gz")
        FileUtils.rm_rf(@full_name)

        stub_installer_read <<-HERE
          {"file": "/foo/bar/#{@release_name}.tar.gz", "version": "#{@version}"}
        HERE

        app.install(@full_name)

        File.directory?(@mytmpdir + @module_name).should == true
        File.file?(@mytmpdir + @module_name + 'metadata.json').should == true
      end.should =~ /Installed #{@release_name.inspect} into directory: #{Regexp.escape(@mytmpdir + @module_name)}/
    end

    it "should install a module from a webserver URL using a version requirement" # TODO

    it "should fail if module isn't a slashed name" do
      run do
        lambda { app.install("invalid") }.should raise_error(SystemExit)
      end.should =~ /Could not install module with invalid name/
    end

    it "should fail if module doesn't exist on webserver" do
      run do
        stub_installer_read "{}"
        lambda { app.install("not-found") }.should raise_error(SystemExit)
      end
    end

    it "should fail gracefully when receiving invalid PSON" do
      pending "Implement PSON error wrapper" # TODO
      run do
        stub_installer_read "1/0"
        lambda { app.install("not-found") }.should raise_error(SystemExit)
      end
    end

    it "should fail if installing a module that's already installed" do
      run do
        name = "myuser-mymodule"
        Dir.mkdir name
        lambda { app.install(name) }.should raise_error(SystemExit)
      end.should =~ /already installed/
    end

  end

  describe "clean" do
    it "should clean cache" do
      run do
        build_and_install_module

        Puppet::Module::Tool::Cache.base_path.directory?.should == true

        app.clean

        Puppet::Module::Tool::Cache.base_path.directory?.should == false
      end
    end
  end

  describe "changes" do
    it "should display changes" do
      run do
        app.generate(@full_name)
        app.build(@full_name)
        Dir.chdir("#{@full_name}/pkg/#{@release_name}")
        File.open("Modulefile", "a") do |handle|
          handle.puts
          handle.puts "# Added"
        end
        puts "CHANGES:"
        app.changes(".")
      end.should match /CHANGES:.+metadata.json\s*Modulefile\s*\z/m
    end
  end

  describe "repository" do
    it "should display repository" do
      run do
        # TODO How to avoid accessing "~/.puppet/puppet.conf" without stubbing parts we want to exercise?
        app.repository
      end.should =~ %r{http://}
    end
  end

end
