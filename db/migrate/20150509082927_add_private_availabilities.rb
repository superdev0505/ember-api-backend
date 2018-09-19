class AddPrivateAvailabilities < ActiveRecord::Migration
  def change
    
    add_column :availabilities, :is_private, :boolean, :default => false
    
  end
end
