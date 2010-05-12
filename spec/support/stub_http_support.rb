def stub_repository_read(code, body)
  kind = Net::HTTPResponse.send(:response_class, code.to_s)
  response = kind.new('1.0', code.to_s, 'HTTP MESSAGE')
  response.stubs(:read_body).returns(body)
  Puppet::Module::Tool::Repository.any_instance.stubs(:read_contact).returns(response)
end

def stub_installer_read(body)
  Puppet::Module::Tool::Applications::Installer.any_instance.stubs(:read_match).returns(body)
end

def stub_cache_read(body)
  Puppet::Module::Tool::Cache.any_instance.stubs(:read_retrieve).returns(body)
end
