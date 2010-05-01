# TODO Figure out why `response.should be_not_found` and `response.should be_forbidden` don't work, whereas `response.should be_success` does. This may be a bug in RSpec, Rack or Rails.

def response_should_be_forbidden
  response.response_code.should == 403
end

def response_should_be_not_found
  response.response_code.should == 404
end