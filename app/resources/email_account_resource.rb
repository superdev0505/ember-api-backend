class EmailAccountResource < JSONAPI::Resource
  attributes :email, :confirmed, :verified, :primary

  has_one :user

  filter :email

end
