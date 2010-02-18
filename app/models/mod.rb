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
  
  validates_format_of :name, :with => /^[[:alnum:]]{2,}$/, :message => "should be 2 or more alphanumeric characters"
  validates_uniqueness_of :name, :scope => [:owner_id, :owner_type]

  validates_format_of :source, :with => /^(git|https?):\/\//, :message => "location invalid (must start with http://, https://, or git://)"

  def full_name
    "#{owner.username}/#{name}"
  end

  def to_param
    name
  end
  
end
