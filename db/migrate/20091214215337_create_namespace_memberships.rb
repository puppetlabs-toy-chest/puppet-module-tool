class CreateNamespaceMemberships < ActiveRecord::Migration
  def self.up
    create_table :namespace_memberships do |t|
      t.integer :namespace_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :namespace_memberships
  end
end
