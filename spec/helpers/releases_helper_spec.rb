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
      helper.label_doc(:name => "MyName").should have_tag("dt", "MyName")
    end

    it "should return Markdown processed documentation if present" do
      helper.label_doc(:name => "MyName", :doc => "*MyDoc*").should have_tag("dd") do
        with_tag("em", "MyDoc")
      end
    end

    it "should return nothing if a name isn't specified" do
      helper.label_doc(:doc => "*MyDoc*").should be_blank
    end

    it "should return the name and documentation if present" do
      result = helper.label_doc(:name => "MyName", :doc => "*MyDoc*")
      result.should have_tag("dt", "MyName")
      result.should have_tag("dd", "MyDoc")
    end

    it "should set HTML attributes if present" do
      helper.label_doc({:name => "MyName"}, {:class => "myclass"}).should have_tag("dl[class=?]", "myclass")
    end

    it "should return nothing if no name or documentation" do
      helper.label_doc(:invalid_key => "Invalid value").should be_blank
    end

    it "should return nothing if called with non-Hash argument" do
      helper.label_doc(:invalid_argument).should be_blank
    end
  end

  describe "link_to_dependency" do
    def should_link(dependency, link)
      helper.link_to_dependency(dependency).should have_tag('a[href=?]', link)
    end

    def should_not_link(dependency)
      helper.link_to_dependency(dependency).should be_nil
    end

    describe "without repository" do
      it "should link to username/modulename" do
        should_link({:name => "foo/bar"}, '/foo/bar')
      end

      it "should link to username-modulename" do
        should_link({:name => 'foo-bar'}, '/foo/bar')
      end

      it "should not link an invalid name" do
        should_not_link({:name => 'foobar'})
      end

      it "should not link if no name" do
        should_not_link({:foo => "bar"})
      end

      it "should not link if invalid type" do
        should_not_link(Hash)
      end
    end

    describe "repository" do
      it "should link to username/modulename" do
        should_link({:repository => "http://foo.bar", :name => "baz/qux"}, "http://foo.bar/baz/qux")
      end

      it "should link to username-modulename" do
        should_link({:repository => "http://foo.bar/", :name => "baz-qux"}, "http://foo.bar/baz/qux")
      end

      it "should not link an invalid name" do
        should_not_link({:repository => "http://foo.bar/", :name => "foobar"})
      end

      it "should not link if no name" do
        should_not_link({:repository => "http://foo.bar", :foo => "bar"})
      end
    end

=begin
it "should link a dashed user-module name" do
      helper.link_to_dependency("name" => "foo-bar").should have_tag("a", "foo/bar")
    end

    it "should link a slashed user/module name" do
      helper.link_to_dependency("name" => "foo/bar").should have_tag("a", "foo/bar")
    end

    it "should not link an invalid name" do
      helper.link_to_dependency("name" => "foobar").should be_nil
    end

    it "should not link to an unnamed item" do
      helper.link_to_dependency("foo" => "bar").should be_nil
    end

    it "should not link to a non-hash" do
      helper.link_to_dependency(mock(Mod)).should be_nil
    end
=end

  end

end

