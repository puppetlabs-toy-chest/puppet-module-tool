class AddRolesToNamespaceMemberships < ActiveRecord::Migration
  def self.up
    change_table :namespace_memberships do |t|
      t.integer :roles, :default => 0
    end
  end

  def self.down
    change_table :namespace_memberships do |t|
      t.remove :roles
    end
  end
end
