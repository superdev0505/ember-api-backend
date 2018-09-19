class AddItemIdToAvailabilityItem < ActiveRecord::Migration[5.0]
  def up
    add_column :availability_resources, :item_id, :integer
    add_column :availability_resources, :item_type, :string

    AvailabilityItem.all.each do |i|
      i.update_attributes(
        item_id: i.resource_id,
        item_type: i.resource_type
      )
    end
  end

  def down
    remove_column :availability_resources, :item_id
    remove_column :availability_resources, :item_type
  end
end
