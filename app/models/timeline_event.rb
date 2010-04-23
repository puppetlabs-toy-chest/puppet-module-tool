# == Schema Information
# Schema version: 20100320030102
#
# Table name: timeline_events
#
#  id                     :integer         not null, primary key
#  event_type             :string(255)
#  subject_type           :string(255)
#  actor_type             :string(255)
#  secondary_subject_type :string(255)
#  subject_id             :integer
#  actor_id               :integer
#  secondary_subject_id   :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class TimelineEvent < ActiveRecord::Base
  belongs_to :actor,              :polymorphic => true
  belongs_to :subject,            :polymorphic => true
  belongs_to :secondary_subject,  :polymorphic => true

  named_scope :for_mods, proc { |*mods|
    {:conditions => {
        'timeline_events.secondary_subject_type' => 'Mod',
        'timeline_events.secondary_subject_id'   => mods.map(&:id)
    }}
  }
  
end
