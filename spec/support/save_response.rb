# Save response body to HTML file
def save_response(target="/tmp/response.html")
  File.open(target, "w") { |h| h.write(response.body) }
  return target
end
