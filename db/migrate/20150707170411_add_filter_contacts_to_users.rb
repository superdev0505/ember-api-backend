class AddFilterContactsToUsers < ActiveRecord::Migration
  def change

    add_column :users, :filter_contacts, :boolean, default: false
  end
end
