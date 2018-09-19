class AddHideWalkthroughToUsers < ActiveRecord::Migration
  def change
    add_column :users, :show_walkthrough, :boolean, default: true
  end
end
