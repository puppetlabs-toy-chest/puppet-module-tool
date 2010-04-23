# == Schema Information
# Schema version: 20100320030102
#
# Table name: watches
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  mod_id     :integer
#  created_at :datetime
#  updated_at :datetime
#

class Watch < ActiveRecord::Base
  belongs_to :user
  belongs_to :mod
end
