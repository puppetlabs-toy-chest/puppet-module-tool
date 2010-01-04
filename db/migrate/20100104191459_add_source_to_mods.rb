class AddSourceToMods < ActiveRecord::Migration
  def self.up
    change_table(:mods) { |t| t.string :source }
  end

  def self.down
    change_table(:mods) { |t| t.remove :source }
  end
end
