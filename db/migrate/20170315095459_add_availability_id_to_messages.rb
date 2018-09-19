class AddAvailabilityIdToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :availability_id, :integer
  end
end
