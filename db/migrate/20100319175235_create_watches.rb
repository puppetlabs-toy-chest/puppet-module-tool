class CreateWatches < ActiveRecord::Migration
  def self.up
    create_table :watches do |t|
      t.integer :user_id
      t.integer :mod_id

      t.timestamps
    end
  end

  def self.down
    drop_table :watches
  end
end
