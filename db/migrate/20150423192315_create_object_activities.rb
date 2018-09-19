class CreateObjectActivities < ActiveRecord::Migration
  def change
    create_table :object_activities do |t|
      t.integer :target_id
      t.string :target_type, :action

      t.string :body
      
      t.timestamps null: false
    end
  
  end
end
