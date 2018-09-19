class CreateLogbookEntries < ActiveRecord::Migration
  def up
    create_table :logbook_entries do |t|
      t.integer :user_id, :target_id
      t.string :target_type, :entry_type, :subject
      t.datetime :date
      t.timestamps null: false
    end

    # Create entries for existing data
    Availability.all.each do |availability|
      # Create a 'taught' entry for the owner
      LogbookEntry.create!(
        user_id: availability.user_id,
        target: availability,
        entry_type: 'taught',
        subject: availability.info,
        date: availability.start_time
      )

      # Create an 'attended' entry for students
      availability.availability_students.each do |join|
        LogbookEntry.create!(
          user_id: join.user_id,
          target: availability,
          entry_type: 'attended',
          subject: availability.info,
          date: availability.start_time
        )
      end
    end

    # Create links for logbook entries
    Reflection.all.each do |reflection|
      LogbookEntry.create!(
        user_id: reflection.user_id,
        target: reflection,
        entry_type: "reflection",
        subject: "Reflection",
        date: reflection.date
      )
    end
  end

  def down
    drop_table :logbook_entries
  end
end
