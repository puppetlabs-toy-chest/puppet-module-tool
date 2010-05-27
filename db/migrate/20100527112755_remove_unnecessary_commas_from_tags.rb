class RemoveUnnecessaryCommasFromTags < ActiveRecord::Migration
  # Tag.all(:conditions => ['name like ?', '%,%'])
  # Tag.all(:conditions => ['name like ?', '%,%']).map(&:taggings).flatten
  
  def self.up
    hit_list = []
    for tag in Tag.all
      sanitized_name = tag.name.gsub(/,|\s+/, '')
      if sanitized_name != tag.name
        if sanitized_tag = Tag.find_by_name(sanitized_name)
          # Another tag was found, so transfer taggings and add to hit list
          for tagging in tag.taggings
            tagging.update_attribute(:tag, sanitized_tag)
          end
          hit_list << tag
        else
          # No other tag found, so rename this one:
          tag.update_attribute(:name, sanitized_name)
        end
      end
    end
    Tag.destroy(hit_list)
  end

  def self.down
    # None.
  end
end
