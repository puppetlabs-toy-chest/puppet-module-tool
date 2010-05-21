require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do

  describe "utilities" do

    describe "redirect_back_or_to" do
      it "should redirect to previous page" do
        @controller.should_receive(:redirect_to).with(:back).and_return("/bar")
        @controller.should_receive(:test).and_return { @controller.send :redirect_back_or_to, "/foo" }

        @controller.send :test
      end

      it "should redirect to default page if no previous page was set" do
        @controller.should_receive(:redirect_to).with(:back).and_raise(ActionController::RedirectBackError)
        @controller.should_receive(:redirect_to).with("/foo").and_return("/foo")
        @controller.should_receive(:test).and_return { @controller.send :redirect_back_or_to, "/foo" }

        @controller.send :test
      end
    end

    describe "notify" do
      it "should notify with default level when given just a message" do
        message = "Hello!"
        @controller.send(:notify_of, message)

        @controller.send(:flash)[:notice].should == message
      end

      it "should notify with specific level when given a message and level" do
        message = "Hello!"
        level = :greeting
        @controller.send(:notify_of, level, message)

        @controller.send(:flash)[level].should == message
      end
    end

    describe "assigns_record" do
      describe "with invalid setup" do
        it "should fail" do
          @controller.stub(:assign_records_by => [Rails])
          lambda { @controller.send(:assign_records) }.should raise_error(ArgumentError)
        end
      end

      describe "with valid setup" do
        # Describe record of +type+ (e.g. User), with +instance+ (e.g. a User
        # record), +key+ (e.g. "myrecord") and whether it is +found+.
        def record_should_be(type, instance=nil, key=nil, found=nil)
          base = type.name.tableize.singularize

          @controller.instance_variable_get("@#{base}").should == instance
          @controller.instance_variable_get("@#{base}_key").should == key
          @controller.instance_variable_get("@#{base}_found").should == found
        end

        before do
          @release = Factory :release
          @mod = @release.mod
          @user = @mod.owner
          @controller.stub(:assign_records_by => [User, Mod, Release])
        end

        it "should assign only a user" do
          @controller.params = { :user_id => @user.to_param }
          @controller.send(:assign_records)

          record_should_be User, @user, @user.to_param, true
          record_should_be Mod
          record_should_be Release
        end

        it "should assign both user and mod" do
          @controller.params = { :user_id => @user.to_param, :mod_id => @mod.to_param }
          @controller.send(:assign_records)

          record_should_be User, @user, @user.to_param, true
          record_should_be Mod,  @mod,  @mod.to_param,  true
          record_should_be Release
        end

        it "should assign the user, mod and release" do
          @controller.params = { :user_id => @user.to_param, :mod_id => @mod.to_param, :id => @release.to_param }
          @controller.send(:assign_records)

          record_should_be User,    @user,    @user.to_param,    true
          record_should_be Mod,     @mod,     @mod.to_param,     true
          record_should_be Release, @release, @release.to_param, true
        end

        it "should identify missing user and stop assigning" do
          user_param = "invalid_user"
          @controller.params = { :user_id => user_param, :mod_id => @mod.to_param, :id => @release.to_param }
          @controller.send(:assign_records)

          record_should_be User, nil, user_param, false
          record_should_be Mod
          record_should_be Release
        end

        it "should identify missing mod and stop assigning" do
          mod_param = "invalid_mod"
          @controller.params = { :user_id => @user.to_param, :mod_id => mod_param, :id => @release.to_param }
          @controller.send(:assign_records)

          record_should_be User, @user, @user.to_param,    true
          record_should_be Mod,  nil,   mod_param,         false
          record_should_be Release
        end

        it "should identify missing release and stop assigning" do
          release_param = "invalid_release"
          @controller.params = { :user_id => @user.to_param, :mod_id => @mod.to_param, :id => release_param }
          @controller.send(:assign_records)

          record_should_be User,    @user,    @user.to_param,    true
          record_should_be Mod,     @mod,     @mod.to_param,     true
          record_should_be Release, nil,      release_param,     false
        end
      end
    end

    describe "ensure_record!" do
      describe "ensure_user!" do
        it "should pass when assigned" do
          @controller.instance_variable_set(:@user_key, "foo")
          @controller.instance_variable_set(:@user_found, true)
          @controller.should_not_receive(:respond_with_not_found)

          @controller.send(:ensure_user!)
        end

        it "should fail when record wasn't found" do
          @controller.instance_variable_set(:@user_key, "foo")
          @controller.instance_variable_set(:@user_found, false)
          @controller.should_receive(:respond_with_not_found).with("Could not find user \"foo\"")

          @controller.send(:ensure_user!)
        end

        it "should fail when nothing is assigned" do
          @controller.instance_variable_set(:@user_key, nil)
          @controller.instance_variable_set(:@user_found, nil)
          @controller.should_receive(:respond_with_not_found).with("Could not find user")

          @controller.send(:ensure_user!)
        end
      end

      describe "ensure_mod!" do
        it "should pass when assigned" do
          @controller.instance_variable_set(:@mod_key, "foo")
          @controller.instance_variable_set(:@mod_found, true)
          @controller.should_not_receive(:respond_with_not_found)

          @controller.send(:ensure_mod!)
        end

        it "should fail when record wasn't found" do
          @controller.instance_variable_set(:@mod_key, "foo")
          @controller.instance_variable_set(:@mod_found, false)
          @controller.should_receive(:respond_with_not_found).with("Could not find module \"foo\"")

          @controller.send(:ensure_mod!)
        end

        it "should fail when nothing is assigned" do
          @controller.instance_variable_set(:@mod_key, nil)
          @controller.instance_variable_set(:@mod_found, nil)
          @controller.should_receive(:respond_with_not_found).with("Could not find module")

          @controller.send(:ensure_mod!)
        end
      end

      describe "ensure_release!" do
        it "should pass when assigned" do
          @controller.instance_variable_set(:@release_key, "foo")
          @controller.instance_variable_set(:@release_found, true)
          @controller.should_not_receive(:respond_with_not_found)

          @controller.send(:ensure_release!)
        end

        it "should fail when record wasn't found" do
          @controller.instance_variable_set(:@release_key, "foo")
          @controller.instance_variable_set(:@release_found, false)
          @controller.should_receive(:respond_with_not_found).with("Could not find release \"foo\"")

          @controller.send(:ensure_release!)
        end

        it "should fail when nothing is assigned" do
          @controller.instance_variable_set(:@release_key, nil)
          @controller.instance_variable_set(:@release_found, nil)
          @controller.should_receive(:respond_with_not_found).with("Could not find release")

          @controller.send(:ensure_release!)
        end
      end
    end

    describe "respond_with_error" do
      it "should be able to access test action" do
        get :test
      end

      it "should fail if called with invalid error" do
        lambda { @controller.send(:respond_with_error, :invalid_error, "Message") }.should raise_error(ArgumentError)
      end

      describe "respond_with_forbidden" do
        it "should render HTML" do
          @controller.should_receive(:test) { @controller.send(:respond_with_forbidden, "Message") }
          get :test, :format => "html"

          response_should_be_forbidden

          # TODO figure out why response body is blank
          ### response.body.should_not be_blank
        end

        it "should render JSON" do
          @controller.should_receive(:test) { @controller.send(:respond_with_forbidden, "Forbidden") }
          get :test, :format => "json"

          response_should_be_forbidden
          response_json["error"].should == "Forbidden"
        end

        it "should render XML" do
          @controller.should_receive(:test) { @controller.send(:respond_with_forbidden, "Forbidden") }
          get :test, :format => "xml"

          response_should_be_forbidden
          assert_select "error", "Forbidden"
        end
      end

      describe "respond_with_not_found" do
        it "should call wrapper" do
          @controller.should_receive(:respond_with_error).with(:not_found, "Message", "Body")
          
          @controller.send(:respond_with_not_found, "Message", "Body")
        end
      end
    end

    describe "admin?" do
      it "should not be true for anonymous" do
        controller.stub!(:current_user => nil)
        controller.send(:admin?).should_not be_true
      end

      it "should not be true for non-admin" do
        controller.stub!(:current_user => Factory(:user))
        controller.send(:admin?).should_not be_true
      end

      it "should be true for admin" do
        controller.stub!(:current_user => Factory(:admin))
        controller.send(:admin?).should be_true
      end
    end

    describe "privileged?" do
      it "should be privileged if in 'development' environment" do
        Rails.stub!(:env => "development")
        controller.send(:privileged?).should be_true
      end

      describe "when in production environment" do
        before do
          Rails.stub!(:env => "production")
        end

        it "should be privileged if logged in as an admin" do
          controller.stub!(:current_user => Factory(:admin))
          controller.send(:privileged?).should be_true
        end

        it "should not be privileged if logged in as a non-admin user" do
          controller.stub!(:current_user => Factory(:user))
          controller.send(:privileged?).should_not be_true
        end

        it "should not be privileged if not logged" do
          controller.send(:privileged?).should_not be_true
        end

      end

    end

  end

end
