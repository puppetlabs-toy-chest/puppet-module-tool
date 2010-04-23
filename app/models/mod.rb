# == Schema Information
# Schema version: 20100320030102
#
# Table name: mods
#
#  id               :integer         not null, primary key
#  name             :string(255)
#  namespace_id     :integer
#  description      :text
#  created_at       :datetime
#  updated_at       :datetime
#  project_url      :string(255)
#  address          :string(255)
#  owner_type       :string(255)
#  owner_id         :integer
#  project_feed_url :string(255)
#

class Mod < ActiveRecord::Base

  # Plugins
  acts_as_taggable_on :tags

  # Associations
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

  has_many :release_events, :as => :secondary_subject do
    def new_releases
      self.all(:conditions => {:event_type => :new_release})
    end
  end

  # Scopes
  named_scope :with_releases, :joins => :releases, :group => 'mods.id', :include => :releases
  named_scope :matching, proc { |q| {:conditions => ['name like ?', "%#{q}%"]} }

  # Validations
  validates_format_of :name, :with => /^[[:alnum:]]{2,}$/, :message => "should be 2 or more alphanumeric characters"
  validates_uniqueness_of :name, :scope => [:owner_id, :owner_type]

  validates_url_format_of(:project_url, :allow_blank => true)
  validates_url_format_of(:project_feed_url, :allow_blank => true)

  # Protection
  attr_protected :id, :owner, :owner_id, :owner_type

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
