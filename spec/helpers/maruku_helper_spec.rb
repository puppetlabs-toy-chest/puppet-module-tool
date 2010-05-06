require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MarukuHelper do

  describe "markdown" do
    
    it "should render HTML" do
      source = <<-HERE
Header
======

* This
* Is
* Markdown
HERE

      target = <<-HERE
<h1 id='header'>Header</h1>

<ul>
<li>This</li>

<li>Is</li>

<li>Markdown</li>
</ul>
HERE
      target.strip!

      helper.markdown(source).should == target
    end

    it "should render empty string as empty string" do
      helper.markdown('').should == ''
    end

    it "should render nil as empty string" do
      helper.markdown('').should == ''
    end

  end

end