class CreateKortextClicks < ActiveRecord::Migration[5.0]
  def change
    return false if ActiveRecord::Base.connection.table_exists? 'kortext_clicks'
    create_table :kortext_clicks do |t|
      t.integer :resource_textbook_id, :user_id
      t.text :emails
      t.string :kortext_link
      t.timestamps null: false
    end
  end
end
