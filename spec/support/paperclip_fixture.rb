# = PaperclipFixture
#
# This class adds test fixtures for use with ActiveRecord models using
# the Paperclip file attachment plugin.
#
# == Examples
#
# Patch a +Release+ model's +:file+ attribute to allow fixtures:
#
#   PaperclipFixture.patch(Release, :file)
#
# Create a file fixture at:
#
#   spec/fixtures/paperclip/releases/myfile.txt
#
#
# Attach this file fixture to a Release record:
#
#   release.file = "myfile.txt"
#
# Or use a factory to create a Release record with this file fixture:
#
#   Factory :release, :file => "myfile.txt"
class PaperclipFixture
  # Directory with Paperclip fixtures.
  cattr_accessor :directory
  self.directory = "#{RAILS_ROOT}/spec/fixtures/paperclip"

  # Return directory with the Paperclip fixtures for this +model+class+.
  #
  # The model-specific fixtures are stored in a subdirectory of the main
  # +::directory+ based on the model class' tableized name (e.g., a
  # Release model class has a "releases" table name).
  def self.directory_for(model_class)
    return File.join(self.directory, model_class.name.tableize)
  end

  # Return filename with the Paperclip fixture for the +model_class+'s
  # +filename+.
  #
  # For example, this call might return the equivalent of
  # `PaperclipFixture.filename_for(Release, "myrelease.tgz")`:
  #
  #   # => "#{RAILS_ROOT}/spec/fixtures/paperclip/releases/myrelease.tgz"
  def self.filename_for(model_class, filename)
    return File.join(self.directory_for(model_class), filename)
  end

  # Return a File handle for the Paperclip fixture for the given
  # +model_class+'s +filename+. See +::filename_for+ for more info.
  def self.file_for(model_class, filename)
    return File.new(self.filename_for(model_class, filename))
  end

  # Patch a +model_class+ so that +attribute_name+ can use Paperclip
  # fixtures.
  #
  # Example:
  # # Patch the +Release+ model's `:file` attribute so it can be used
  # with Paperclip fixtures:
  #   PaperclipFixture.patch(Release, :file)
  def self.patch(model_class, attribute_name)
    return true if model_class.instance_methods.include?("#{attribute_name}_with_paperclip_fixture")

    model_class.class_eval(<<-HERE, __FILE__, __LINE__)
p :patch
      # Add class-wide toggle to model for enabling the fixtures:
      cattr_accessor :paperclip_fixture_enabled
      self.paperclip_fixture_enabled = true

      # Patch setter
      def #{attribute_name}_with_paperclip_fixture=(value)
        if self.class.paperclip_fixture_enabled
          # Don't create attachments for fixtures
          def self.save_attached_files
            return true
          end

          # Don't destroy attachments for fixtures
          def self.destroy_attached_files
            return true
          end
          if value.kind_of?(String)
            # Read file from a fixture
            handle = PaperclipFixture.file_for(self.class, value)
            self.#{attribute_name}_without_paperclip_fixture = handle
            self.#{attribute_name}_without_paperclip_fixture.instance_write(:file_name, value)
            self.#{attribute_name}_without_paperclip_fixture.instance_write(:file_size, handle.size)
            self.#{attribute_name}_without_paperclip_fixture.instance_write(:updated_at, handle.ctime)
          else
            # Use original behavior
            self.#{attribute_name}_without_paperclip_fixture = value
          end
        else
          # Use original behavior
          return self.#{attribute_name}_without_paperclip_fixture = value
        end
      end
      alias_method_chain :#{attribute_name}=, :paperclip_fixture

      # Patch getter
      def #{attribute_name}_with_paperclip_fixture(*args)
        if self.class.paperclip_fixture_enabled
          # TODO
          def (self.#{attribute_name}_without_paperclip_fixture).path(*moreargs)
            PaperclipFixture.filename_for(self.instance.class, self.original_filename)
          end
          return self.#{attribute_name}_without_paperclip_fixture(*args)
        else
          # Use original behavior
          return self.#{attribute_name}_without_paperclip_fixture(*args)
        end
      end
      alias_method_chain :#{attribute_name}, :paperclip_fixture
HERE
  end
end

__END__

# Sample code to exercise fixture from `script/console`
reload!
load 'spec/support/paperclip_fixture.rb'
PaperclipFixture.patch Release, :file
o = Release.new(:file => "mymodule-0.0.1.tar.gz")
o.file.exists?
o.file.to_file
