class AddFullnameToMod < ActiveRecord::Migration
  def self.up
    add_column :mods, :full_name, :string
    Mod.reset_column_information
    for mod in Mod.all
      mod.update_full_name!
    end
  end

  def self.down
    remove_column :mods, :full_name
  end
end
