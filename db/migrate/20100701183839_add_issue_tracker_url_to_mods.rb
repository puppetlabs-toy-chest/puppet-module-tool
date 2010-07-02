class AddIssueTrackerUrlToMods < ActiveRecord::Migration
  def self.up
    add_column :mods, :project_issues_url, :string
  end

  def self.down
    remove_column :mods, :project_issues_url
  end
end
