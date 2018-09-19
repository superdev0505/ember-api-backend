class FeedbackQuestionResponse < ApplicationRecord
  
  belongs_to :feedback
  belongs_to :feedback_question
  
end
