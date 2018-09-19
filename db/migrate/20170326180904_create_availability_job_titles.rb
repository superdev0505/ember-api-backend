class CreateAvailabilityJobTitles < ActiveRecord::Migration[5.0]
  def up
    create_table :availability_job_titles do |t|
      t.integer :availability_id, :job_title_id
      t.timestamps
    end

    # Create links by looking at target experience min and max
    jobTitles = JobTitle.all
    Availability.all.each do |availability|
      next if availability.target_experience_min.blank? | availability.target_experience_max.blank?
      jts = jobTitles.select{|a| a.position >= availability.target_experience_min && a.position <= availability.target_experience_max}
      jts.each do |jt|
        AvailabilityJobTitle.create!(
          availability_id: availability.id,
          job_title_id: jt.id
        )
      end
    end
  end

  def down
    drop_table :availability_job_titles
  end
end
