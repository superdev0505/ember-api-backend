class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.integer :user_id, :target_id
      
      t.text :comments, :done_well, :to_improve
      
      t.boolean :signed_off
      
      t.timestamp :read_at
      
      t.timestamps null: false
    end
  end
end
