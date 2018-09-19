class AddCompletedNotesToAvailabilities < ActiveRecord::Migration[5.0]
  def change
    add_column :availabilities, :completed_notes, :text
  end
end
