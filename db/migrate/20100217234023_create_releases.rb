class CreateReleases < ActiveRecord::Migration
  def self.up
    create_table :releases do |t|
      t.string :version
      t.integer :mod_id
      t.text :notes
      t.timestamps
    end
    add_index :releases, :version
  end

  def self.down
    drop_table :releases
  end
end
