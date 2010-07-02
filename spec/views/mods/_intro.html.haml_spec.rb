require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "mods/_intro.html.haml" do
  shared_examples_for "with release" do
    it "should link to the release" do
      should have_tag("p a[href=?]", vanity_release_path(@user, @mod, @release), "Version #{@release.version}")
    end

    it "should show the release date" do
      should have_text(/#{@release.created_at.to_date.to_s(:long)}/)
    end
  end

  shared_examples_for "without release" do
    it "should say there's no release" do
      should have_tag("p", "Not released")
    end
  end

  shared_examples_for "with docs" do
    it "should have docs" do
      should have_tag("div.introduction", @mod.description)
    end
  end

  shared_examples_for "without docs" do
    it "should not have docs" do
      should_not have_tag("div.introduction")
    end
  end

  describe "with a release" do
    before :each do
      @user = Factory :user
      @mod = Factory :mod, :owner => @user
      @release = Factory :release, :mod => @mod
      @mod.reload
    end

    describe "and docs" do
      before :each do
        render :partial => "mods/intro", :locals => { :mod => @mod, :docs => true }
      end
      subject { response }

      it_should_behave_like "with release"
      it_should_behave_like "with docs"
    end

    describe "but without docs" do
      before :each do
        render :partial => "mods/intro", :locals => { :mod => @mod, :docs => false}
      end
      subject { response }

      it_should_behave_like "with release"
      it_should_behave_like "without docs"
    end
  end

  describe "without a release" do
    before :each do
      @user = Factory :user
      @mod = Factory :mod, :owner => @user
      render :partial => "mods/intro", :locals => { :mod => @mod }
    end
    subject { response }

    it_should_behave_like "without release"
  end
end
