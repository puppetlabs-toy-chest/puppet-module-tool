# == Schema Information
# Schema version: 20100320030102
#
# Table name: releases
#
#  id                :integer         not null, primary key
#  version           :string(255)
#  mod_id            :integer
#  notes             :text
#  created_at        :datetime
#  updated_at        :datetime
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  metadata          :text
#

class Release < ActiveRecord::Base

  # Paperclip plugin:
  has_attached_file :file, :url => "/system/releases/:bucket/:owner/:owner-:mod_name-:version.tar.gz"

  # Associations
  belongs_to :mod

  # Validations
  validates_presence_of :version
  validates_uniqueness_of :version, :scope => :mod_id
  validate :validate_version

  # Serialize fields using YAML
  serialize :metadata

  # TODO Implement TimelineEvent
=begin
  fires(:new_release,
        :on => :create,
        :secondary_subject => :mod,
        :actor => :owner)
=end

  # Delegate methods to other records
  delegate :owner, :to => :mod

  # Return unique human-readable string key for this record.
  def to_param
    return self.version
  end

  # Return a guess of what the next version would be.
  def guess_next_version
    current = Versionomy.parse(version)
    return current.release_type == :final ?
      current.bump(:tiny) :
      current.bump(:release_type)
  end

  # Return the record's metadata or an empty hash.
  def metadata
    return read_attribute(:metadata) || {}
  end

  # Validate the record's :version attribute and set errors if needed.
  def validate_version
    begin
      Versionomy.parse(self.read_attribute(:version))
    rescue => e
      self.errors.add('version', e.message)
    end

    unless self.mod
      self.errors.add_to_base("No associated module.")
    end

    unless self.file
      self.errors.add_to_base("No file provided")
    end
  end

  # Set the :metadata attribute by reading the release's file.
  def extract_metadata!
    tgz = Zlib::GzipReader.new(File.open(self.file.path, 'rb'))
    Archive::Tar::Minitar::Input.open(tgz) do |inp|
      inp.each do |entry|
        if File.basename(entry.full_name) == 'metadata.json'
          raw = entry.read
          data = JSON.parse(raw) rescue {}
          update_attribute(:metadata, data)
          break
        end
      end
    end
  end
  
end
