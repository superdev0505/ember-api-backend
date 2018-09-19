class FeedbackQuestionResource < JSONAPI::Resource

  attributes :question_type, :title, :position, :created_at, :updated_at

  has_many :feedback_question_responses

end
