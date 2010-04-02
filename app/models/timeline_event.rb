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
