class RemoveTitleFromModule < ActiveRecord::Migration
  def self.up
    change_table(:mods) { |t| t.remove :title }
  end

  def self.down
    change_table(:mods) { |t| t.string :title }
  end
end
