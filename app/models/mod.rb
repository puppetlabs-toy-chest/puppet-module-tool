class Mod < ActiveRecord::Base

  acts_as_taggable_on :tags

  belongs_to :owner, :polymorphic => true
  has_many :releases do
    def ordered
      sort_by { |release| Versionomy.parse(release.version) }.reverse
    end
    def current
      ordered.first
    end
  end

  has_many :watches
  has_many :watchers, :through => :watches, :source => :user

  named_scope :with_releases, :joins => :releases, :group => 'mods.id', :include => :releases
  named_scope :matching, proc { |q| {:conditions => ['name like ?', "%#{q}%"]} }
  
  validates_format_of :name, :with => /^[[:alnum:]]{2,}$/, :message => "should be 2 or more alphanumeric characters"
  validates_uniqueness_of :name, :scope => [:owner_id, :owner_type]

  validates_url_format_of(:project_url, :allow_blank => true)
  validates_url_format_of(:project_feed_url, :allow_blank => true)
  
  def full_name
    "#{owner.username}/#{name}"
  end

  def to_param
    name
  end

  def version
    current_release = releases.ordered.first
    if current_release
      current_release.version
    end
  end

  def watchable_by?(user)
    if user == owner
      false
    else
      true
    end
  end

  def watched_by?(user)
    watchers.include?(user)
  end
  
end
