class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.integer :user_id
      t.string :filename
      t.timestamps null: false
    end

    create_table :certificates_logbook_entries, id: false do |t|
      t.integer :certificate_id, :logbook_entry_id
    end
  end
end
