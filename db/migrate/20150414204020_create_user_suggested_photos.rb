class CreateUserSuggestedPhotos < ActiveRecord::Migration
  def change
    create_table :user_suggested_photos do |t|
      t.integer :user_id
      t.string :url, :source

      t.timestamps null: false
    end
  end
end
