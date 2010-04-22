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

  end

end
