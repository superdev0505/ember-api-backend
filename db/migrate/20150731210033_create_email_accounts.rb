class CreateEmailAccounts < ActiveRecord::Migration
  def up
    create_table :email_accounts do |t|
      t.integer :user_id
      t.string :email, null: false
      t.string :confirmation_token
      t.boolean :confirmed, :verified, :primary, default: false, null: false
      t.timestamps null: false
    end

    # Add a verified flag to Users (true if they have at least one verified email account)
    add_column :users, :verified, :boolean, default: false, null: false

    User.all.each do |user|
      EmailAccount.create!(
        user_id: user.id,
        email: user.email,
        primary: true,
        confirmed: !user.confirmed_at.blank?
      )
    end

    add_index :email_accounts, :confirmation_token

  end

  def down
    drop_table :email_accounts
    remove_column :users, :verified
  end
end
