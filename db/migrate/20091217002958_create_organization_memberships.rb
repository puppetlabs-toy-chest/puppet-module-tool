class CreateOrganizationMemberships < ActiveRecord::Migration
  def self.up
    create_table :organization_memberships do |t|
      t.integer :user_id
      t.integer :organization_id
      t.integer :roles

      t.timestamps
    end
  end

  def self.down
    drop_table :organization_memberships
  end
end
