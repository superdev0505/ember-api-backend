class Feedback < ApplicationRecord

  belongs_to :user # Teacher receiving feedback
  belongs_to :target, :class_name => "User" # Student giving feedback
  has_one :feedback_request
  belongs_to :availability

  has_many :feedback_question_responses

  has_many :object_activities, :as => :target

  default_scope { order(created_at: :desc) }

  visitable class_name: "Visit"

  # Delegate methods of the associated feedback request i.e. description and reflection
  delegate :event_description, :event_reflection, :event_time, :to => :feedback_request

  # Update notifications updated_at value on change
  has_many :notifications, as: :target
  def update_notifications
    if changed?
      notifications.each{|a| a.update_attribute(:target_updated_at, updated_at)}
    end
  end
  after_save :update_notifications

#   def blank_feedback?
# #    if comments.blank? && to_improve.blank? && done_well.blank?
# #      errors.add(:base, "Please enter some feedback")
# #    end
#     # likert_counter = (1..LIKERT_FIELDS.length).to_a
# #     free_text_counter = (1..FREE_TEXT_FIELDS.length).to_a
# #     if(likert_counter.all?{|a| self["likert_#{a}"].blank?} && free_text_counter.all?{|a| self["free_text_#{a}"].blank?})
# #       errors.add(:base, "Please enter some feedback")
# #     end
#   end
#   validate :blank_feedback?


  # DEPRECATED
  # Now loaded from Availability model
  def self.get_pdf_markup(feedbacks, user)
    return <<-EOF

  	pdf.repeat :all do
  		pdf.transparent(0.05) do
  			pdf.draw_text("Oslr    Oslr", :at => [20, 125], :rotate => 45, :size => 75)
  		end
  	end

  	pdf.text "Oslr Certificate of Teaching", :size => 25, :style => :bold
  	pdf.text "This is to certify that #{user.name} has taught the following tutorials:", :size => 15

  	pdf.move_down(30)

  	@feedbacks.each_with_index do |feedback, i|


  			pdf.horizontal_rule
  			pdf.move_down 10

        pdf.text "Received " + feedback.created_at.strftime('%d/%m/%Y')

        feedback.feedback_question_responses.each do |response|
          pdf.text response.feedback_question.title
          if response.feedback_question.question_type == "likert"
            pdf.text response.score.to_s + " / 5"
          elsif response.feedback_question.question_type == "text"
            pdf.text response.body
          end
        end


  		pdf.move_down(30)


  	end

  	pdf.move_down(30)
  	pdf.text("The above feedback was collected through Oslr.")

    EOF
  end

#
#   def verified_feedback?
#     (!student.nil? && !student.confirmed_at.nil?) || (!feedback_request.nil? && User::ALLOWED_EMAILS.any?{|reg| !(feedback_request.email.downcase =~ reg).nil?})
#   end


  after_create :notify!

  # Notify the person receiving feedback that they have received it
  # Mark notifications linked to the feedback request as read
  def notify!

    Alert.alert!(target, self, "create")

    # alert = Alert.create!(
    #   user: target,
    #   target: self,
    #   text: "Feedback received from #{self.user.name}",
    #   read_link: "/app/main/feedbacks/show/#{id}"
    # )

    # # Create notifications for the sender and receiver -> will appear in timeline
    # Notification.create!(
    #   user_id: user.id, target: self,
    #   notify: false,
    #   unread: false
    # )
    # Notification.create!(
    #   user_id: target.id, target: self,
    #   notify: true,
    #   unread: true
    # )

  end

end
