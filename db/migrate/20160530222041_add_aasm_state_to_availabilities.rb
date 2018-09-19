class AddAasmStateToAvailabilities < ActiveRecord::Migration
  def up
    add_column :availabilities, :aasm_state, :string

    # Set past sessions to 'completed' and future ones to 'confirmed'
    Availability.all.each do |a|
      state = ""
      if a.cancelled
        state = "cancelled"
      elsif a.start_time < Time.now
        state = 'completed'
      else
        state = 'confirmed'
      end
      a.update_attribute(:aasm_state, state)
    end
  end

  def down
    remove_column :availabilities, :aasm_state
  end
end
