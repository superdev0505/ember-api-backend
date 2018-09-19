class FeedbackQuestionResponseResource < JSONAPI::Resource

  attributes :body, :score, :created_at, :updated_at

  has_one :feedback
  has_one :feedback_question

end
