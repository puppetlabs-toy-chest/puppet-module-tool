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

  # Protection
  attr_accessible :version, :notes, :file

  # Paperclip plugin:
  has_attached_file :file, :url => "/system/releases/:bucket/:owner/:owner-:mod_name-:version.tar.gz"

  # Associations
  belongs_to :mod

  # Validations
  validates_presence_of :version
  validates_uniqueness_of :version, :scope => :mod_id
  validate :validate_version
  validate :validate_mod
  validate :validate_file
  validate :validate_metadata

  # Serialize fields using YAML
  serialize :metadata

  # Triggers
  before_destroy :destroy_attachment

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
    raise ArgumentError, "No version specified" unless self.version
    current = Versionomy.parse(self.version)
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
    unless self.errors.on(:version)
      begin
        Versionomy.parse(self.read_attribute(:version))
      rescue => e
        self.errors.add('version', e.message)
      end
    end
  end

  # Validate the record's mod and set errors if needed.
  def validate_mod
    unless self.mod
      self.errors.add_to_base("No associated module.")
    end
  end

  # Validate the record's file and set errors if needed.
  def validate_file
    unless self.file.file?
      self.errors.add :file, "must be provided"
      return false
    end
  end

  def validate_metadata
    if self.file.file?
      return self.extract_metadata!
    end
  end

  # Set the :metadata attribute by reading the release's file.
  def extract_metadata!
    if self.file.file?
      self.logger.info "Release#extract_metadata! - got file"
      begin
        archive = Zlib::GzipReader.new(self.file.to_file)
        self.logger.info "Release#extract_metadata! - parsed gzip file"
      rescue Zlib::GzipFile::Error
        self.errors.add :file, "must be a 'tar.gz' file"
        self.logger.info "Release#extract_metadata! - not a gzip file"
        return false
      end

      Archive::Tar::Minitar::Input.open(archive) do |handle|
        self.logger.info "Release#extract_metadata! - opened tar file"
        handle.each do |entry|
          # TODO validate checksum of entry
          # TODO validate that there's only a single directory in root and nothing else
          # TODO validate that there's on a single 'metadata.json' at the top of the base directory
          # FIXME this finds the first match, not the right match
          if File.basename(entry.full_name) == 'metadata.json'
            # TODO validate that the metadata's name matches the mod name?
            # TODO validate that the metadata's version matches the release version?
            self.logger.info "Release#extract_metadata! - found metadata.json"
            raw = entry.read
            begin
              self.metadata = JSON.parse(raw)
              # TODO validate that metadata contains useful information
              self.logger.info "Release#extract_metadata! - parsed metadata: #{self.metadata.inspect}"
              break
            rescue JSON::ParserError => e
              self.errors.add :file, "must contain a 'metadata.json' file that's valid JSON" 
              self.logger.info "Release#extract_metadata! - invalid JSON: #{e.message}"
              return false
            end
          end
        end

        if self.metadata.empty?
          self.errors.add :file, "must contain a valid 'metadata.json' file"
          self.logger.info "Release#extract_metadata! - empty metadata"
          return false
        else
          return true
        end
      end
    end
  end

  # Destroy the file attachment when destroying the release record.
  def destroy_attachment
    self.file.destroy
  end

end
