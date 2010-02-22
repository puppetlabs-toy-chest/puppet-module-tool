class AddMetadataToReleases < ActiveRecord::Migration
  def self.up
    change_table(:releases) { |t| t.text :metadata }
  end

  def self.down
    change_table(:releases) { |t| t.remove :metadata }
  end
end
