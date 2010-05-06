# Return a file attachment based on the fixture at +filename+. An optional
# +content_type+ can be provided, but will be guessed otherwise.
def attachment_fixture_for(filename, content_type=nil)
  content_type ||= begin
    extname = File.extname(filename)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(extname) ?
      mime_type.to_s :
      'application/octet-stream'
  end
  return ActionController::TestUploadedFile.new("#{RAILS_ROOT}/spec/attachments/#{filename}", content_type)
end