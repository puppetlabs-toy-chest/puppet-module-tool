require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FocusHelper do
  it "should focus on an identifier" do
    helper.focus(:identifier).should =~ /#{Regexp.escape("$('#identifier').focus()")}/m
  end
end
