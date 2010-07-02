require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "mods/show.html.haml" do
  before :each do
    @release, @mod, @user = populated_release_and_mod_and_user

    assigns[:releases] = [@release]
    assigns[:release] = @release
    assigns[:mod] = @mod
    assigns[:user] = @user
  end

  describe "menubar" do
    it "should not be shown to unauthorized users" do
      template.stub!(:can_change? => false)
      render
      subject { response }

      should_not have_tag(".minimenubar")
    end

    describe "when shown to authorized users" do
      before :each do
        template.stub!(:can_change? => true)
        render
        subject { response }

        should have_tag(".minimenubar")
      end

      it "should have an 'Add release' link" do
        should have_tag(".minimenubar a[href=?]", new_user_mod_release_path(@user, @mod), /Add release/)
      end

      it "should have an 'Edit module' link" do
        should have_tag(".minimenubar a[href=?]", edit_user_mod_path(@user, @mod), /Edit module/)
      end

      it "should have an 'Delete module' link" do
        should have_tag(".minimenubar a[href=?]", user_mod_path(@user, @mod), /Delete module/)
      end
    end
  end
end
