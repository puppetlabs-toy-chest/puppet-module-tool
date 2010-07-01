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

  # Protection
  attr_accessible :name, :description, :project_url, :address, :project_feed_url, :project_issues_url, :tag_list

  # Plugins
  acts_as_taggable_on :tags

  # Associations
  belongs_to :owner, :class_name => "User"
  belongs_to :current_release, :class_name => "Release"
  has_many :releases, :dependent => :destroy do
    def ordered
      sort_by { |release| Versionomy.parse(release.version) }.reverse
    end

    # Return current Release through expensive calculation. Return cached result with Mod#current_release.
    def current
      ordered.first
    end
  end

  # Triggers
  before_validation :set_full_name

  # TODO Implement Watches
=begin
  has_many :watches
  has_many :watchers, :through => :watches, :source => :user

  has_many :release_events, :as => :secondary_subject do
    def new_releases
      self.all(:conditions => {:event_type => :new_release})
    end
  end
=end

  # Scopes
  named_scope :with_releases, :joins => :releases, :group => 'mods.id', :include => [:owner, :releases, :current_release, :tags]
  named_scope :with_current_release, :joins => :releases, :group => 'mods.id', :include => [:owner, :current_release, :tags]
  named_scope :matching, proc { |q| {:conditions => ['lower(mods.full_name) like ?', "%#{q.downcase}%"]} }
  named_scope :ordered, :order => 'lower(full_name) asc'

  # Validations
  validates_format_of :name, :with => /\A[[:alnum:]]{1,}\z/, :message => "should be 1 or more alphanumeric characters"
  validates_uniqueness_of :name, :scope => [:owner_id, :owner_type]

  validates_url_format_of(:project_url, :allow_blank => true)
  validates_url_format_of(:project_feed_url, :allow_blank => true)
  validates_url_format_of(:project_issues_url, :allow_blank => true)

  # Return unique human-readable string key for this record.
  def to_param
    return self.name
  end

  # Return the current version of this mod, or nil.
  def version
    if self.current_release
      return self.current_release.version
    end
  end

  # Can this +user+ change this record?
  def can_be_changed_by?(user)
    return user && (user.admin? || user == self.owner)
  end

  # Set the record's :full_name cache.
  def set_full_name
    self.full_name = self.raw_full_name
  end

  # Update the record's full_name cache and save record.
  def update_full_name!(user=nil)
    if value = self.raw_full_name(user)
      self.update_attribute(:full_name, value)
    end
  end

  # Return the record's full name (e.g., "username/modulename") by doing a query.
  def raw_full_name(user=nil)
    user ||= self.owner
    return [user.username, self.name].join('/') if user
  end

  # Update the record's current release cache.
  def update_current_release!
    self.logger.debug("Mod#update_current_release!")
    # The `releases(true)` refetches the association.
    self.update_attribute(:current_release, self.releases(true).current)
  end

  # Set the #tag_list but remove unnecessary commas and extra spaces
  def tag_list_with_sanitizer=(value)
    self.tag_list_without_sanitizer = value.present? ? value.gsub(/,|\s+/, ' ') : nil
  end
  alias_method_chain :tag_list=, :sanitizer

  # TODO Implement Watches
=begin
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
=end
  
end
