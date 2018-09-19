require 'aasm'

class Availability < ApplicationRecord

  # Uses acts_as_state_machine to transition between:
  # => Proposed
  # => Confirmed
  # => Completed
  # => Cancelled


  belongs_to :user

  validates_presence_of :start_time, :end_time#, :user_id#, :max_students

  # Signed up students:
  # has_many :availability_students
  # has_many :users, through: :availability_students

  # New system
  has_many :availability_users
  has_many :users, through: :availability_users


  has_many :availability_specialties
  has_many :specialties, through: :availability_specialties

  has_one :conversation
  has_many :messages

  has_many :object_activities, :as => :target

  belongs_to :location

  has_many :feedbacks
  has_many :feedback_requests

  has_many :availability_invites
  has_many :availability_items

  has_many :availability_job_titles
  has_many :job_titles, through: :availability_job_titles

  visitable class_name: "Visit"

  # after_create :notify!
  # def notify!
  #
  #   users = (watching_users + [user]).uniq
  #
  #   users.each do |target_user|
  #
  #     if target_user == user
  #       Notification.create!(
  #         user: target_user,
  #         target: self,
  #         notify: true,
  #         unread: false
  #       )
  #     else
  #       Notification.create!(
  #         user: target_user,
  #         target: self,
  #         notify: false,
  #         unread: true
  #       )
  #     end
  #   end
  #
  # end

  # Alert interested users on create
  # Ignore the creating user
  def alert_watching_users
    Alert.alert!(watching_users - [user], self, "create", "A new teaching session was posted by #{user.name}")
  end
  after_create :alert_watching_users

  # On any change, make sure interested users see updates
  def websocket_update
    return false unless ActiveRecord::Migrator.current_version >= 20170318122919
    json = self.to_jsonapi
    watching_users.each do |user|
      next if id_changed? && user == self.user # Leave out the creating user on create (id_changed? tests for record creation)
      UpdatesChannel.broadcast_to(user, {loadModels: [json]})
    end
  end
  after_save :websocket_update

  # Update notifications updated_at value on change
  has_many :notifications, as: :target
  def update_notifications
    if changed?
      notifications.each{|a| a.update_attribute(:target_updated_at, updated_at)}
    end
  end
  after_save :update_notifications

  after_save :make_log
  def make_log
    LogbookEntry.make_entry_for(self) if aasm_state == "completed"
  end

  # Users whose should be informed about this availability on creation
  def watching_users

    # Start with people who are signed up
    signed_up = User.joins(:availability_users).where(:availability_users => {:availability => self})

    # Ignore this for private sessions
    return signed_up if is_private

    # Find users who are looking for the parameters set by this available teacher

    # Find them by job title, location and specialties they're interested in
    # IGNORE UNVERIFIED USERS
    # users = User.joins(:job_title).where(
    #   ["users.verified = ? AND job_titles.position >= ? AND job_titles.position <= ?", true, target_experience_min, target_experience_max]
    # )
    users = User

    if specialties
      # Return users who either have no interests set, or whose interests overlap with this session
      ids = specialties.collect{|a| a.id}
      users = users.joins("LEFT JOIN user_interests ON user_interests.user_id = users.id").where("(users.user_interests_count = ?) OR user_interests.specialty_id IN (?)", 0, ids)
    end

    # Hospitals...
    if location
      users = users.joins(:locations).where(:locations => {:id => location})
    end

    signed_up.all + users.all
  end

  # People with admin rights for this session
  def admins
    availability_users.where(admin: true).includes(:user).all.collect{|a| a.user}
  end

  # Find the students and teachers
  def students
    availability_users.includes(:user).where(:teacher => false).all.collect{|a| a.user}
  end
  def teachers
    availability_users.includes(:user).where(:teacher => true).all.collect{|a| a.user}
  end

  # Sign up a user to this teaching session
  def sign_up!(student, aasm_state = :confirmed, inviter_id = nil)
    # Don't allow if it's full
    return false if !is_private && availability_users.where(teacher: false).count >= max_students
    # Don't allow if it's cancelled
    return false if cancelled
    # Don't allow if they're already signed up
    return false unless availability_users.where(:user_id => student.id).first.nil?
    # Don't allow if they created the session
    return false if student.id.to_s == self.user_id.to_s

    availability_users.create!(user_id: student.id, teacher: false, aasm_state: aasm_state, inviter_id: inviter_id)

    # Add to any conversations linked to the availability object
    if conversation
      conversation.users << student
      conversation.cache_active_users!
    end

    # Notify this user of any further changes
    notification = Notification.where(:user => student, :target => self).first
    notification = Notification.create!(:user => student, :target => self) if notification.nil?
    notification.update_attribute(:notify, true) if notification

    return true
  end

  # Similar to above but creates an invite rather than adding to the users list
  def invite!(student, user)
    sign_up!(student, :invited, user.id)
    # # Don't allow if they're already signed up
    # return false unless availability_students.where(:user_id => student.id).first.nil?
    # # Don't allow if they have an invite they haven't responded to yet
    # return false unless availability_invites.where(:student_id => student.id, :responded => false).first.nil?
    # # Don't allow if they created the session
    # return false if student.id.to_s == self.user_id.to_s
    #
    # invite = availability_invites.create!(user_id: user.id, student_id: student.id)
    #
    # # Add to any conversations linked to the availability object
    # if conversation
    #   conversation.users << student
    #   conversation.cache_active_users!
    # end
    #
    # # Notify this user of any further changes
    # notification = Notification.where(:user => student, :target => self).first
    # notification = Notification.create!(:user => student, :target => self) if notification.nil?
    # notification.update_attribute(:notify, true) if notification
    #
    # return invite
  end

  def cancel_sign_up!(student)
    availability_student = availability_students.where(:user_id => student.id).first
    if availability_student
      availability_student.destroy

      # Remove from any conversations linked to the availability object
      if conversation
        ConversationMember.where(:conversation_id => conversation.id, :user_id => student.id).each{|a| a.destroy}
        conversation.cache_active_users!
      end

      # Don't notify this user of any further changes
      notification = Notification.where(:user => student, :target => self).first
      notification.update_attribute(:notify, false) if notification
      return true
    end
    return false
  end

  # Cancel the session, notify signed up students
  def do_cancel!
    update_attributes(cancelled: true, cancelled_at: Time.now)
#    update_attribute(:end_time, Time.now) if end_time > Time.now
  end



  # Define states:
  include AASM
  aasm do
    state :proposed, :initial => true
    state :confirmed, :completed, :cancelled


    event :confirm do
      transitions from: :proposed, to: :confirmed, guard: :can_confirm?
    end

    event :complete do
      transitions from: :confirmed, to: :complete, guard: :can_complete?
    end

    event :cancel, before: :do_cancel! do
      transitions from: [:proposed, :confirmed, :completed], to: :cancelled
    end

  end


  # Determines if enough information is present to transition to 'confirmed' state
  def can_confirm?
    !start_time.blank? && !end_time.blank? && !location_id.blank? && availability_students.length > 0
  end

  def can_complete?
    can_confirm? && start_time <= Time.now
  end


  def self.get_pdf_markup(logbook_entries, user)
    return <<-EOF

    # Add the font style and size
    pdf.font "Helvetica"
    pdf.font_size 18

  	pdf.repeat :all do
      # Watermark pages
  		pdf.transparent(0.05) do
  			pdf.draw_text("Oslr    Oslr", :at => [20, 125], :rotate => 45, :size => 75)
  		end

      # Logo
      logopath = "#{Rails.root}/public/app_logo.png"
      pdf.image logopath, :width => 48, :height => 48

      # ID box in top right
      logtext = "Oslr Logbook for #{ user.name }"
      logtext += " #{user.gmc}" if #{!user.gmc.nil?}
      pdf.text_box logtext, :align => :right

      pdf.font_size 18
  	end

    # Page 1: Summary
  	pdf.text "Oslr Certificate of Teaching", :size => 25, :style => :bold
  	pdf.text "Teaching log for #{user.name}", :size => 15
    if #{!user.gmc.nil?}
      pdf.text "GMC number: #{user.gmc}"
    end

    pdf.move_down(150)
    pdf.text "Summary of contents:"
    @logbook_entries.group_by(&:entry_type).each do |type, entries|
      case type
      when "taught"
        str = "sessions taught"
      when "attended"
        str = "sessions attended"
      when "reflection"
        str = "reflective logs"
      else
        next
      end
      pdf.text entries.count.to_s + " " + str
    end



  	@logbook_entries.each_with_index do |logbook_entry, i|

      pdf.start_new_page
      pdf.move_down(50)

      if logbook_entry.entry_type == 'taught' || logbook_entry.entry_type == 'attended'
        availability = logbook_entry.target



        pdf.font_size 20
        if availability.user_id == #{user.id}
          pdf.text "Taught tutorial"
        else
          pdf.text "Attended tutorial by " + availability.user.name
        end

        pdf.move_down 10
        pdf.horizontal_rule
  			pdf.move_down 10
        pdf.font_size 14

        pdf.text availability.start_time.strftime("%H:%M - ") + availability.end_time.strftime("%H:%M on %d/%m/%Y")
        pdf.text availability.info
        pdf.text availability.location.name if availability.location

        if availability.user_id == #{user.id}
          pdf.horizontal_rule
  			  pdf.move_down 10

          pdf.text "Received " + availability.feedbacks.count.to_s + " feedback forms"

          pdf.move_down 10
          availability.feedbacks.each do |feedback|

            pdf.bounding_box([50, pdf.cursor], width: 400) do
              feedback.feedback_question_responses.sort_by{|a| a.feedback_question.position}.each do |response|
                pdf.text response.feedback_question.title
                if response.feedback_question.question_type == "likert"
                  pdf.text response.score.to_s + " / 5"
                elsif response.feedback_question.question_type == "text"
                  pdf.text response.body
                end
              end
            end
            pdf.move_down 10
          end

  		pdf.move_down(30)
    end # End of feedbacks

    elsif logbook_entry.entry_type == "reflection"
      pdf.text "Reflection"
      reflection = logbook_entry.target
      pdf.text reflection.body
      pdf.text reflection.date.strftime("%d/%m/%Y")


  end
  pdf.move_down(30)

  # Page numbers
  pdf.font_size 14

  pdf.bounding_box([pdf.bounds.right - 50,pdf.bounds.bottom], :width => 60, :height => 20) do
    count = pdf.page_count
    pdf.text "Page " + count.to_s
  end

end

  	pdf.move_down(30)
  	pdf.text("The above feedback was collected through Oslr.")

    EOF
  end


end
