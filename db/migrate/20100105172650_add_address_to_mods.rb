class AddAddressToMods < ActiveRecord::Migration
  def self.up
    change_table(:mods) { |t| t.string :address }
    change_table(:namespaces) { |t| t.string :address }    
  end

  def self.down
    change_table(:mods) { |t| t.remove :address }
    change_table(:namespaces) { |t| t.remove :address }
  end
end
