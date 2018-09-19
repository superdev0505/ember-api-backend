class AddAasmStateToAvailabilityStudents < ActiveRecord::Migration
  def up
    add_column :availability_students, :aasm_state, :string
    add_column :availability_students, :admin, :boolean, default: false
    add_column :availability_students, :teacher, :boolean, default: false
    add_column :availability_students, :invited_by, :integer

    # Create availability_student objects from invites
    AvailabilityInvite.all.each do |invite|
      as = AvailabilityStudent.where(availability_id: invite.availability_id, user_id: invite.student_id).first
      AvailabilityStudent.create!(
        availability_id: invite.availability_id,
        invited_by: invite.user_id,
        user_id: invite.student_id
      ) if as.nil?
    end
  end

  def down
    # TODO: recreate availability_invites

    remove_column :availability_students, :aasm_state
    remove_column :availability_students, :admin
    remove_column :availability_students, :teacher
    remove_column :availability_students, :invited_by
  end
end
