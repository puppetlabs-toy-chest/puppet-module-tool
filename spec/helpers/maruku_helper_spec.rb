require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MarukuHelper do

  describe "markdown" do

    # Return +HTML+ in a DIV with a "markeddown" class.
    def markeddown(html)
      content_tag(:div, html, :class => "markeddown")
    end
    
    it "should render HTML" do
      source = <<-HERE
Header
======

* This
* Is
* Markdown
HERE

      target = <<-HERE
<h1>Header</h1>

<ul>
<li>This</li>

<li>Is</li>

<li>Markdown</li>
</ul>
HERE
      target.strip!

      helper.markdown(source).should == markeddown(target)
    end

    it "should render empty string as nil" do
      helper.markdown('').should be_nil
    end

    it "should render nil as nil" do
      helper.markdown('').should be_nil
    end

    it "should strip out forbidden HTML tags" do
      helper.markdown("<blink>blinky</blink>").should == markeddown("blinky")
    end

    it "should strip out forbidden HTML attributes" do
      helper.markdown("<p onclick='1/0'>clicky</p>").should == markeddown("<p>clicky</p>")
    end

    it "should fix unclosed HTML tags" do
      helper.markdown("<b>bold").should == markeddown("<b>bold</b>")
    end

  end

end