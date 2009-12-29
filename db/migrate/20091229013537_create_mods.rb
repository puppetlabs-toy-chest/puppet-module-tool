class CreateMods < ActiveRecord::Migration
  def self.up
    create_table :mods do |t|
      t.string :name
      t.integer :namespace_id
      t.string :title
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :mods
  end
end
