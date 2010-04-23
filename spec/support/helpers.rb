module ResponseHelpers

  def response_json
    JSON.parse(response.body)
  end

  # Returns path unauthenticated user is redirected to when accessing path
  # protected by the #authenticate_user! filter.
  def unauthenticated_session_path
    return new_user_session_url(:unauthenticated => true)
  end

end
