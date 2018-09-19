class CreateFeedbackQuestions < ActiveRecord::Migration
  def up
    create_table :feedback_questions do |t|
      t.string :question_type
      t.string :title
      t.integer :position
      t.timestamps null: false
    end
    
    # Pre-populate
    FeedbackQuestion.create!([
      {
        :question_type => :likert,
        :title => "The teaching was enjoyable",
        :position => 1
      },
      {
        :question_type => :likert,
        :title => "I learned something new",
        :position => 2
      },
      {
        :question_type => :likert,
        :title => "The teaching was relevant to my studies",
        :position => 3
      },
      {
        :question_type => :likert,
        :title => "I would recommend this session to a colleague",
        :position => 4
      },
      {
        :question_type => :text,
        :title => "What was done well",
        :position => 5
      },
      {
        :question_type => :text,
        :title => "Areas to improve",
        :position => 6
      },
      {
        :question_type => :text,
        :title => "Any other comments",
        :position => 7
      }
    ])
  end
  
  def down
    drop_table :feedback_questions
  end
end
