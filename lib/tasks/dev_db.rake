namespace :dev_db do
  desc "Setup test users for a test DB"
  task populate_db: :environment do


    # Different users should include:
    # => Several fully confirmed and validated users to interact with each other
    # => An unverified user
    # => An unconfirmed user
    # => A verified user with an incomplete profile
    #
    # All users have a common password

    password = "testing123"

    loc1 = Location.first
    loc2 = Location.offset(1).first

    for i in 1..12 do
      u = User.create!(
        name: "Oslrtest #{i}",
        email: "test#{i}@oslr.co.uk",
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
    u.locations << loc2


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
    # f1 = Feedback.create!(
    #   user_id: u.id, target_id: u2.id, availability_id: a1.id
    # )
    # f1 = Feedback.create!(user_id: u.id, target_id: u2.id, availability_id: a1.id)
    # f2 = Feedback.create!(
    #   user_id: u2.id, target_id: u.id, availability_id: a1.id
    # )

  end


  # Reset the database from scratch
  task reset_db: :environment do
    Rake::Task["db:migrate:reset"].invoke
    Rake::Task["db:seed"].invoke
    Rake::Task["dev_db:populate_db"].invoke
  end
end
