class AddAvailabilityIdAndReflectionIdToLogbookEntries < ActiveRecord::Migration[5.0]
  def up
    add_column :logbook_entries, :availability_id, :integer
    add_column :logbook_entries, :reflection_id, :integer

    LogbookEntry.all.each do |entry|
      if entry.target_type == "Availability"
        entry.update_attribute(:availability_id, entry.target_id)
      end

      if entry.target_type == "Reflection"
        entry.update_attribute(:reflection_id, entry.target_id)
      end
    end
  end

  def down
    remove_column :logbook_entries, :availability_id
    remove_column :logbook_entries, :reflection_id
  end
end
