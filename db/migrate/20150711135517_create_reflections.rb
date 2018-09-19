class CreateReflections < ActiveRecord::Migration
  def change
    create_table :reflections do |t|
      t.integer :user_id
      t.datetime :date
      t.text :body
      t.timestamps null: false
    end
  end
end
