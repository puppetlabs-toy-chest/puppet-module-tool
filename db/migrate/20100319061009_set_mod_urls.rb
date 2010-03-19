class SetModUrls < ActiveRecord::Migration
  def self.up
    change_table :mods do |t|
      t.rename :source, :project_url
      t.string :project_feed_url
    end
  end

  def self.down
    change_table :mods do |t|
      t.rename :project_url, :source
      t.remote :project_feed_url
    end
  end
end
