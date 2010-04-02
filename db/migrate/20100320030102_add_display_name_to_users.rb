class AddDisplayNameToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :display_name
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :display_name
    end
  end
end
