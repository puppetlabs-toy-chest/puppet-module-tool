require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "mods/_document.html.haml" do
  def render_document(document)
    render :partial => "mods/document", :locals => {:document => document}
  end

  shared_examples_for "a module" do
    it "should have a link to the project homepage" do
      should have_tag("a[href=?]", @mod.project_url)
    end

    it "should have a link to the module owner" do
      should have_tag("a[href=?]", user_path(@user))
    end

    it "should have a markeddown description" do
      should have_tag(".mod_description") do
        with_tag(".markeddown", @mod.description)
      end
    end
  end

  shared_examples_for "a release" do
    it "should have a download link" do
      should have_tag("a.download-link[href=?]", @release.file.url(:default, false), "Download")
    end

    it "should have markeddown release notes" do
      should have_tag(".mod_description") do
        with_tag(".markeddown", @release.notes)
      end
    end
  end

  describe "when rendering a module" do
    describe "with a release" do
      before :each do
        @release, @mod, @user = populated_release_and_mod_and_user

        render_document @mod
      end
      subject { response }

      it_should_behave_like "a module"

      it_should_behave_like "a release"
    end

    describe "without a release" do
      before :each do
        @mod, @user = populated_mod_and_user

        render_document @mod
      end
      subject { response }

      it_should_behave_like "a module"

      it "should not have a release download link" do
        should_not have_tag("a.download-link")
      end

      it "should not have a release version" do
        should have_text(/No releases/)
      end
    end
  end

  describe "when rendering a release" do
    before :each do
      @release, @mod, user = populated_release_and_mod_and_user
    end

    # Render @release.
    def render_release
      render_document(@release)
    end

    def set_release_metadata_to(hash)
      @release.metadata.merge!(hash)
      @release.update_attribute(:metadata, @release.metadata)
    end

    it "should not have a dependencies section if there aren't any" do
      render_release
      subject { response }

      should_not have_tag(".dependencies")
    end

    describe "with module dependencies" do
      def it_should_have_dependencies(dependencies=nil, &block)
        if dependencies
          set_release_metadata_to "dependencies" => dependencies
        end

        render_release
        subject { response }

        should have_tag(".dependencies") do
          with_tag("h3") do
            with_text "Dependencies"
          end
          if block
            block.call
          end
        end
      end

      it "should have links to the dependencies" do
        it_should_have_dependencies([{"name" => "otheruser-othermodule" }]) do
          with_tag("a[href=?]", "/otheruser/othermodule")
        end
      end

      it "should display versions of dependencies if specified" do
        it_should_have_dependencies([{
          "name" => "otheruser-othermodule",
          "version_requirement" => "0.0.1",
        }]) do
          with_text /0.0.1/
        end
      end
    end

    it "should not have a types section if there aren't any" do
      render_release
      subject { response }

      should_not have_tag(".dependencies")
    end

    describe "with types" do
      def it_should_have_types(types=nil, &block)
        if types
          set_release_metadata_to "types" => types
        end
        render_release
        subject { response }
        should have_tag(".types") do
          with_tag("h3", "Types")
          if block
            block.call
          end
        end
      end

      describe "with an empty type" do
        before :each do
          it_should_have_types([{}])
        end

        it "should not display the name" do
          should_not have_tag ".type_name"
        end

        it "should not display the parameters" do
          should_not have_tag ".type_parameters"
        end

        it "should not display the properties" do
          should_not have_tag ".type_properties"
        end

        it "should not display the providers" do
          should_not have_tag ".type_providers"
        end
      end

      it "should display name if specified" do
        it_should_have_types([{
            "name" => "typename"
        }]) do
          with_tag(".type_name", "typename")
        end
      end

      def it_should_display_type_details_for(kind, &block)
        plural = kind.to_s.pluralize
        singular = kind.to_s.singularize
        it_should_have_types([{
          "#{plural}" => {
            "my#{singular}_name" => "my#{singular}_doc"
          }
        }]) do
          with_tag(".type_#{singular}") do
            with_tag(".type_#{singular}") do
              with_text /my#{singular}_name/
              with_text /my#{singular}_doc/
            end
          end
        end

      end

      it "should display parameters if specified" do
        it_should_display_type_details_for :parameters
      end

      it "should display properties if specified" do
        it_should_display_type_details_for :properties
      end

      it "should display providers if specified" do
        it_should_display_type_details_for :providers
      end
    end
  end
end
