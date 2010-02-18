class AddAttachmentsFileToRelease < ActiveRecord::Migration
  def self.up
    add_column :releases, :file_file_name, :string
    add_column :releases, :file_content_type, :string
    add_column :releases, :file_file_size, :integer
  end

  def self.down
    remove_column :releases, :file_file_name
    remove_column :releases, :file_content_type
    remove_column :releases, :file_file_size
  end
end
