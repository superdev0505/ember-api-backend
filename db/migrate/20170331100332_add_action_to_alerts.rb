class AddActionToAlerts < ActiveRecord::Migration[5.0]
  def change
    add_column :alerts, :action, :string
  end
end
