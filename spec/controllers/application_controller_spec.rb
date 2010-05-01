require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do

  context "utilities" do

    context "redirect_back_or_to" do
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

    context "notify" do
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

  end

end
