class RemoveOrganizationOwner < ActiveRecord::Migration
  def self.up
    change_table(:organizations) do |t|
      t.remove :owner_id
    end
  end

  def self.down
    change_table(:organizations) do |t|
      t.integer :owner_id
    end
  end
end
