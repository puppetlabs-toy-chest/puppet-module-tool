class AddPublicKeyToUsers < ActiveRecord::Migration
  def self.up
    change_table(:users) { |t| t.text :public_key }
  end

  def self.down
    change_table(:users) { |t| t.remove :public_key }
  end
end
