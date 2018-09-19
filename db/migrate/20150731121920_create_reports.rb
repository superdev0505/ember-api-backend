class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :target_id, :user_id, :report_category_id
      t.string :target_type
      t.text :body, :response
      t.boolean :closed, default: false
      t.timestamps null: false
    end

    add_column :availabilities, :blocked, :boolean, default: false
    add_column :messages, :blocked, :boolean, default: false
    add_column :users, :blocked, :boolean, default: false
    add_column :feedbacks, :blocked, :boolean, default: false
  end
end
