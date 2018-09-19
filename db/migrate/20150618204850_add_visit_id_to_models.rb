class AddVisitIdToModels < ActiveRecord::Migration
  def change
    
    [:messages, :feedback_requests, :feedbacks, :availabilities, :availability_students].each do |tab|
      add_column tab.to_sym, :visit_id, :string, limit: 36
    end
    
  end
end
