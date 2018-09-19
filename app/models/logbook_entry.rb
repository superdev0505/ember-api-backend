class LogbookEntry < ApplicationRecord

  belongs_to :user
  belongs_to :target, polymorphic: true

  belongs_to :availability
  belongs_to :reflection

  has_and_belongs_to_many :certificates

  default_scope { order(created_at: :desc) }

  # Called by after_save methods of models e.g. availability, availability_student, reflection
  # Creates logbook entry or brings up to date
  def self.make_entry_for(object)


    mytarget = object
    user = object.user
    case object.class.to_s
    when "Reflection"
      entry_type = 'reflection'
      subject = "Reflection"
      date = object.date
    when "Availability"
      entry_type = 'taught'
      subject = object.info
      date = object.start_time
    when "AvailabilityStudent"
      mytarget = object.availability
      entry_type = 'attended'
      subject = object.availability.info
      date = object.availability.start_time
    # Version 2 replaces AvailabilityStudents with AvailabilityUsers
    when "AvailabilityUser"
      # Options: :interested, :invited, :confirmed, :cancelled, :rejected, :attended, :dna
      # Only create logs for attended sessions
      return false if object.aasm_state != "attended"
      mytarget = object.availability
      entry_type = object.teacher ? 'taught' : 'attended'
      subject = object.availability.info
      date = object.availability.start_time
    else
      entry_type = object.class.to_s.downcase
      subject = ""
      date = object.created_at
    end

    entry = LogbookEntry.where(:user_id => user.id, :target => mytarget).first
    if entry.nil?
      entry = LogbookEntry.new(:user_id => user.id, :target => mytarget)
    end

    entry.entry_type = entry_type
    entry.subject = subject
    entry.date = date

    entry.save!

    # ObjectActivity.faye_broadcast(user, entry)
  end

  # In transition from V1, we now record the availability_id and reflection_id as appropriate
  before_save :update_models
  def update_models
    return false unless ActiveRecord::Migrator.current_version >= 20170318122919
    self.availability_id = self.target_id if self.target_type == "Availability"
    self.reflection_id   = self.target_id if self.target_type == "Reflection"
  end


  # Update via websockets on save
  def websocket_update
    UpdatesChannel.broadcast_to(user, {loadModels: [self.to_jsonapi]})
  end
  after_save :websocket_update

end
