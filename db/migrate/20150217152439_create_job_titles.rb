class CreateJobTitles < ActiveRecord::Migration
  def change
    create_table :job_titles do |t|
      t.string :name
      t.integer :position
      t.boolean :qualified
    end
    
    add_column :users, :job_title_id, :integer
  end
end
