require 'test_helper'

class AlertTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "broadcasts after save" do

    u = User.last
    target = Availability.last
    alert = Alert.new(user: u, target: target, read_link: "/availabilities/#{target.id}")
    assert alert.save

    # TODO: how to test actionCable broadcasting?

    assert alert.destroy
  end
end
