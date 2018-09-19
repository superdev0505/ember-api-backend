require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "Email account created on creation" do
    id = rand(10**10)
    pw = "testing123"
    userdata = {
      email: "user_#{id}@oslr.co.uk",
      name: "User #{id}",
      password: pw,
      password_confirmation: pw
    }

    user = User.new(userdata)

    user_count = User.count
    email_count = EmailAccount.count

    assert user.save!

    assert_equal user_count + 1, User.count
    assert_equal email_count + 1, EmailAccount.count

    em = EmailAccount.last
    user.reload
    assert_equal em.user_id, user.id
    assert_equal em.email, user.email

    assert !user.primary_email_account.nil?
    assert_equal user.primary_email_account.email, user.email
  end


end
