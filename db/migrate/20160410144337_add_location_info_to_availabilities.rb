class AddLocationInfoToAvailabilities < ActiveRecord::Migration
  def change
    add_column :availabilities, :location_info, :text
  end
end
