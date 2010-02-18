class Release < ActiveRecord::Base

  has_attached_file :file, :url => "/system/releases/:bucket/:owner/:owner-:mod_name-:version.tar.gz"
  
  belongs_to :mod
  validates_presence_of :version
  validates_uniqueness_of :version, :scope => :mod_id

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
  
end
