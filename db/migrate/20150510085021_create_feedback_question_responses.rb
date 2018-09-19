class CreateFeedbackQuestionResponses < ActiveRecord::Migration
  def up
    create_table :feedback_question_responses do |t|
      t.integer :feedback_id, :feedback_question_id
      t.text :body # For free text
      t.integer :score # For likerts
      t.timestamps null: false
    end
    
    # Map existing feedback to this system
    done_well  = FeedbackQuestion.where(position: 5).first
    to_improve = FeedbackQuestion.where(position: 6).first
    comments   = FeedbackQuestion.where(position: 7).first
    
    Feedback.all.each do |feedback|
      unless feedback.done_well.blank?
        FeedbackQuestionResponse.create!(
          feedback_id: feedback.id,
          feedback_question_id: done_well.id,
          body: feedback.done_well
        )
      end
      
      unless feedback.to_improve.blank?
        FeedbackQuestionResponse.create!(
          feedback_id: feedback.id,
          feedback_question_id: to_improve.id,
          body: feedback.to_improve
        )
      end
      
      unless feedback.comments.blank?
        FeedbackQuestionResponse.create!(
          feedback_id: feedback.id,
          feedback_question_id: comments.id,
          body: feedback.comments
        )
      end
      
    end
    
    remove_column :feedbacks, :done_well
    remove_column :feedbacks, :to_improve
    remove_column :feedbacks, :comments
  end
  
  def down
    add_column :feedbacks, :done_well, :text
    add_column :feedbacks, :to_improve, :text
    add_column :feedbacks, :comments, :text
    
    done_well  = FeedbackQuestion.where(position: 5).first
    to_improve = FeedbackQuestion.where(position: 6).first
    comments   = FeedbackQuestion.where(position: 7).first
    
    Feedback.all.each do |feedback|
      tmp = feedback.feedback_question_responses.where(:feedback_question => done_well).first
      feedback.update_attribute(:done_well, tmp.body) if tmp
      
      tmp = feedback.feedback_question_responses.where(:feedback_question => to_improve).first
      feedback.update_attribute(:to_improve, tmp.body) if tmp
      
      tmp = feedback.feedback_question_responses.where(:feedback_question => comments).first
      feedback.update_attribute(:comments, tmp.body) if tmp
    end
    
    drop_table :feedback_question_responses
  end
end
