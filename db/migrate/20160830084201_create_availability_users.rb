class CreateAvailabilityUsers < ActiveRecord::Migration[5.0]
  def up
    create_table :availability_users do |t|
      t.integer :user_id, :availability_id
      # User may be a student or a teacher
      t.boolean :teacher, default: false
      # Can they edit the details?
      t.boolean :admin, default: false
      # Join model includes invitations
      t.integer :inviter_id
      # Can have multiple states
      t.string :aasm_state
      t.timestamps
    end

    # Copy existing join models across
    AvailabilityStudent.all.each do |as|
      AvailabilityUser.create!(
        user_id: as.user_id,
        availability_id: as.availability_id,
        aasm_state: 'confirmed'
      )
    end

    # Need to create a new model for session creators
    Availability.all.each do |a|
      AvailabilityUser.create!(
        user_id: a.user_id,
        availability_id: a.id,
        aasm_state: 'confirmed',
        teacher: true,
        admin: true
      )
    end

    AvailabilityInvite.all.each do |ai|
      AvailabilityUser.create!(
        user_id: ai.student_id,
        availability_id: ai.availability_id,
        inviter_id: ai.user_id,
        aasm_state: (ai.accepted ? 'confirmed' : 'rejected')
      )
    end
  end

  def down
    drop_table :availability_users
  end
end
