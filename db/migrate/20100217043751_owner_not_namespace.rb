class OwnerNotNamespace < ActiveRecord::Migration
  def self.up
    drop_table :organizations
    drop_table :namespace_memberships
    drop_table :organization_memberships
    drop_table :namespaces
    change_table(:mods) do |t|
      t.string  :owner_type
      t.integer :owner_id
    end
  end

  def self.down
    change_table(:mods) do |t|
      t.remove :owner_id, :owner_type
    end
    # No down
  end
end
