class LinkFeedbackToAvailabilities < ActiveRecord::Migration
  def change

    add_column :feedback_requests, :availability_id, :integer
    add_column :feedbacks, :availability_id, :integer

  end
end
