    # This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# For realistic data, populate with a sanitised copy of the real DB
# unless Rails.env.production?
#   connection = ActiveRecord::Base.connection
#   connection.tables.each do |table|
#     connection.execute("TRUNCATE #{table}") unless table == "schema_migrations"
#   end
#
#   sql = File.read('db/oslr_demo_safe.sql')
#   statements = sql.split(/;$/)
#   statements.pop
#
#   ActiveRecord::Base.transaction do
#     statements.each do |statement|  
#       connection.execute(statement)
#     end
#   end
# end


# Job Titles
JobTitle.create([
  {name: "Medical Student - Pre-clinical", position: 1, qualified: false},
  {name: "Medical Student - Year 3", position: 2, qualified: false},
  {name: "Medical Student - Year 4", position: 3, qualified: false},
  {name: "Medical Student - Final Year", position: 4, qualified: false},
  {name: "FY1", position: 5, qualified: true},
  {name: "FY2", position: 6, qualified: true},
  {name: "SHO (ST1-2)", position: 7, qualified: true},
  {name: "SpR", position: 8, qualified: true},
  {name: "Consultant", position: 9, qualified: true},
  {name: "GP", position: 9, qualified: true}
])

student = JobTitle.where(:name => "Medical Student - Year 3").first
student5 = JobTitle.where(:name => "Medical Student - Final Year").first
f1 = JobTitle.where(:name => "FY1").first
f2 = JobTitle.where(:name => "FY2").first
spr = JobTitle.where(:name => "SpR").first

# Locations

mse = Location.create(name: "Mount St Elsewhere")
kch = Location.create(name: "King's College Hospital", latitude: 51.4683569, longitude: -0.09230590000004213)
guys = Location.create(name: "Guy's Hospital", latitude: 51.5027999, longitude: -0.08962870000004841)
sth = Location.create(name: "St Thomas' Hospital", latitude: 51.49790789999999, longitude: -0.11967070000002877)

ucl = Location.create(name: "University College London")
worthing = Location.create(name: "Worthing Hospital")
margate = Location.create(name: "Margate Hospital")


# Specialties
%w(Cardiology Respiratory Emergency GP).each do |spec|
  Specialty.create!(name: spec)
end


# Setup several dummy users
password = "testing123"
loc1 = mse
loc2 = margate

for i in 1..12 do
  u = User.create!(
    name: "Oslrtest #{i}",
    email: "test#{i}@oslr.co.uk",
    password: password,
    password_confirmation: password,
    bio: "Lorem ipsum make water"
  )
  u.confirm
  u.update_attribute(:verified, true)
  u.update_attribute(:terms, true)

  # Complete the profile
  jt = JobTitle.offset(i % JobTitle.count).first
  u.job_title = jt
  u.save!

  # Put these all in loc1
  u.locations << loc1
end

# SAME AS ABOVE BUT IN loc2

u = User.create!(
  name: "Oslrtest Otherlocation",
  email: "test_other_location@oslr.co.uk",
  password: password,
  password_confirmation: password
)
u.confirm
u.update_attribute(:verified, true)
u.update_attribute(:terms, true)

# Complete the profile
jt = JobTitle.offset(i % JobTitle.count).first
u.job_title = jt
u.save!

# Put these in loc2
# u.locations << loc2


# TODO: Multiple locations
# TODO: specialities and interests


# Confirmed and verified but profile incomplete
u = User.create!(
  name: "Oslrtest Profileincomplete",
  email: "test_incomplete_profile@oslr.co.uk",
  password: password,
  password_confirmation: password
)
u.confirm
u.update_attribute(:verified, true)
u.update_attribute(:terms, true)

# Unverified
u = User.create!(
  name: "Oslrtest Unverified",
  email: "test_unverified@oslr.co.uk",
  password: password,
  password_confirmation: password
)
u.confirm
u.update_attribute(:verified, false)
u.update_attribute(:terms, true)

# unconfirmed
u = User.create!(
  name: "Oslrtest Unconfirmed",
  email: "test_unconfirmed@oslr.co.uk",
  password: password,
  password_confirmation: password
)
u.update_attribute(:terms, true)


# Hasn't accepted T&Cs
u = User.create!(
  name: "Oslrtest Noterms",
  email: "test_no_terms@oslr.co.uk",
  password: password,
  password_confirmation: password
)
u.confirm
u.update_attribute(:verified, true)
u.update_attribute(:terms, false)


# Regular complete user - should have all types of notification
u = User.create!(
  name: "Oslrtest Notifications",
  email: "test_notifications@oslr.co.uk",
  password: password,
  password_confirmation: password
)
u.confirm
u.update_attribute(:verified, true)
u.update_attribute(:terms, true)
jt = JobTitle.offset(i % JobTitle.count).first
u.job_title = jt
UserLocation.create!(:user_id => u.id, :location_id => loc1.id)
u.save!


# Setup notifications for this user
# => Availability they've created
# => Availability they've signed up to
# => Availability recommended for them but not signed up to
# => Availability they're invited to
# => Feedback request they have sent
# => Feedback request they have received
# => Feedback they have sent
# => Feedback they have received
# => Message received
#
# Use user 10 as the one to interact with
u2 = User.where(email: "test10@oslr.co.uk").first
opts = {
  start_time: Time.now - 1.hour, end_time: Time.now + 1.hour,
  max_students: 6,
  location_id: loc1.id
}

a1 = Availability.create!(opts.merge({user: u, info: "A1 - created"}))
a2 = Availability.create(opts.merge({user: u2, info: "A2 - signed up"}))
a2.sign_up!(u)
a3 = Availability.create(opts.merge({user: u2, info: "A3 - watching"}))
a4 = Availability.create(opts.merge({user: u2, info: "A4 - invited"}))
a4.invite!(u, u2)
u.generateAvailabilityNotifications

# Create a feedback request by the user
fr = FeedbackRequest.create!(
  user_id: u.id, target_id: u2.id, availability_id: a1.id
)
fr2 = FeedbackRequest.create!(
  user_id: u2.id, target_id: u.id, availability_id: a2.id
)





# Specialties
specs = [
  "Allergy",
  "Anaesthetics",
  "Cardiology",
  "Cardio-thoracic surgery",
  "Oncology",
  "Pharmacology and therapeutics",
  "Radiology",
  "Infectious diseases",
  "Sexual and reproductive health",
  "Dermatology",
  "Emergency medicine",
  "Endocrinology and diabetes",
  "Gastroenterology",
  "General (internal) medicine",
  "General practice",
  "Psychiatry",
  "General surgery",
  "Genito-urinary medicine",
  "Geriatric medicine",
  "Haematology",
  "Histopathology",
  "Immunology",
  "Intensive care medicine",
  "Microbiology",
  "Ophthalmology",
  "Neurology",
  "Neurosurgery",
  "Obstetrics and gynaecology",
  "Oral and maxillo-facial surgery ",
  "Paediatrics",
  "Palliative medicine",
  "Plastic surgery",
  "Renal medicine",
  "Respiratory medicine",
  "Rheumatology",
  "Trauma and orthopaedic surgery",
  "Tropical medicine",
  "Urology",
  "Vascular surgery"
]
specs.sort.each do |spec|
  Specialty.create(name: spec)
end
Specialty.create(name: "Other")
