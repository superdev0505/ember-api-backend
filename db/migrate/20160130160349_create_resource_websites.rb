class CreateResourceWebsites < ActiveRecord::Migration
  def change
    create_table :resource_websites do |t|
      t.integer :user_id
      t.string :name, :url
      t.text :description
      t.timestamps null: false
    end
  end
end
