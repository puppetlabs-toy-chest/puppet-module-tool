require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "mods/_list.html.haml" do
  describe "without modules" do
    before :each do
      assigns[:mods] = [].paginate
      assigns[:mods_count] = 0

      render
    end

    subject do
      response
    end

    it "should have no modules" do
      should have_tag("p", "No modules found.")
    end
  end

  describe "with modules" do
    before :each do
      @user = Factory :user
      @released_mod = Factory :mod, :owner => @user, :created_at => 1.week.ago
      @release = Factory :release, :mod => @released_mod, :created_at => 1.day.ago
      @unreleased_mod = Factory :mod, :owner => @user, :created_at => 2.weeks.ago

      assigns[:mods] = [@released_mod, @unreleased_mod].paginate
      assigns[:mods_count] = 2
    end

    shared_examples_for "with modules" do
      it "should have modules count" do
        should have_tag("p", "2 modules found.")
      end

      it "should have link to a module" do
        should have_tag("a[href=?]", module_path(@user, @released_mod))
      end

      it "should have link to a module's owner" do
        should have_tag("a[href=?]", user_path(@user))
      end

      it "should have module HTML data attributes for JavaScript" do
        should have_tag("li.mod_link[data-mod_link=?]", module_path(@user, @released_mod))
      end
    end

    describe "with highlighting" do
      before :each do
        params[:q] = "my"
        render
      end

      subject do
        response
      end

      it_should_behave_like "with modules"

      it "should highlight matches" do
        should have_tag("li.mod_link[data-mod_link=?]", module_path(@user, @released_mod)) do
          with_tag "a[href=?]", user_path(@user) do
            with_tag "span class=search_highlight", "my"
            with_text "user"
          end

          with_tag "a[href=?]", module_path(@user, @released_mod) do
            with_tag "span class=search_highlight", "my"
            with_text "module"
          end
        end

        should have_tag("li.mod_link[data-mod_link=?]", module_path(@user, @unreleased_mod)) do
          with_tag "a[href=?]", user_path(@user) do
            with_tag "span class=search_highlight", "my"
            with_text "user"
          end

          with_tag "a[href=?]", module_path(@user, @unreleased_mod) do
            with_text "anothermodule"
          end
        end
      end
    end

    describe "without highlighting" do
      before :each do
        render
      end

      subject do
        response
      end

      it_should_behave_like "with modules"

      it "should not highlight matches" do
        should have_tag("li.mod_link[data-mod_link=?]", module_path(@user, @released_mod)) do
          with_tag "a[href=?]", user_path(@user), "myuser"
          with_tag "a[href=?]", module_path(@user, @released_mod), "mymodule"
        end

        should have_tag("li.mod_link[data-mod_link=?]", module_path(@user, @unreleased_mod)) do
          with_tag "a[href=?]", user_path(@user), "myuser"
          with_tag "a[href=?]", module_path(@user, @unreleased_mod), "anothermodule"
        end
      end
    end
  end
end
