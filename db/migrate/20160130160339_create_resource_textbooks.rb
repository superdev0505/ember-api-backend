class CreateResourceTextbooks < ActiveRecord::Migration
  def change
    create_table :resource_textbooks do |t|
      t.string :user_id
      t.string :name, :isbn, :kortext_link, :img_link
      t.text :description
      t.timestamps null: false
    end
  end
end
