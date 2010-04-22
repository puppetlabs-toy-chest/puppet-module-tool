class Release < ActiveRecord::Base

  has_attached_file :file, :url => "/system/releases/:bucket/:owner/:owner-:mod_name-:version.tar.gz"
  
  belongs_to :mod
  validates_presence_of :version
  validates_uniqueness_of :version, :scope => :mod_id

  serialize :metadata

  fires(:new_release,
        :on => :create,
        :secondary_subject => :mod,
        :actor => :owner)

  delegate :owner, :to => :mod

  def to_param
    version
  end

  def guess_next_version
    current = Versionomy.parse(version)
    if current.release_type == :final
      current.bump(:tiny)
    else
      current.bump(:release_type)
    end
  end

  def metadata
    read_attribute(:metadata) || {}
  end

  def validate
    begin
      Versionomy.parse(read_attribute(:version))
    rescue => e
      errors.add('version', e.message)
    end
    unless mod
      errors.add_to_base("No associated module.")
    end
    unless file
      errors.add_to_base("No file provided")
    end
  end

  def extract_metadata!
    tgz = Zlib::GzipReader.new(File.open(file.path, 'rb'))
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
