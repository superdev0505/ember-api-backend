class CreateReportCategories < ActiveRecord::Migration
  def change
    create_table :report_categories do |t|
      t.string :name
    end

    ["Shared patient information", "Inappropriate/offensive content", "Other"].each do |name|
      ReportCategory.create!(:name => name)
    end
  end
end
