# Return JSON parsed from the response body.
def response_json
  return JSON.parse(response.body)
end

# Returns path unauthenticated user is redirected to when accessing path
# protected by the #authenticate_user! filter.
def unauthenticated_session_path
  return new_user_session_url(:unauthenticated => true)
end

# Response shouuld redirect the user to the login page.
def response_should_redirect_to_login
  response.should redirect_to(unauthenticated_session_path)
end

# Response should be "HTTP 403 Forbidden".
def response_should_be_forbidden
  # TODO Figure out why `response.should be_not_found` and `response.should be_forbidden` don't work, whereas `response.should be_success` does. This may be a bug in RSpec, Rack or Rails.
  response.response_code.should == 403
end

# Response should be "HTTP 404 Not Found".
def response_should_be_not_found
  response.response_code.should == 404
end