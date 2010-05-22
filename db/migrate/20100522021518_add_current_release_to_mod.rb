class AddCurrentReleaseToMod < ActiveRecord::Migration
  def self.up
    add_column :mods, :current_release_id, :integer
    Mod.reset_column_information
    Mod.all.each do |mod|
      mod.update_current_release!
      # if release = mod.releases.current
        # mod.current_release = release
        # mod.save!
      # end
    end
  end

  def self.down
    remove_column :mods, :current_release_id
  end
end
