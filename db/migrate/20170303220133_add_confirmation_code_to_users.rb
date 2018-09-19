class AddConfirmationCodeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :email_accounts, :confirmation_code, :string
  end
end
