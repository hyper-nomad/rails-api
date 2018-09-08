[
  {email: 'user1@example.com', password:'test1234'},
  {email: 'user2@example.com', password:'test1234'}
].each{|u|
  user = SignedUser.find_or_initialize_by email: u[:email]
  user.skip_confirmation!
  user.password = u[:password]
  user.password_confirmation = u[:password]
  user.save!
}
UnsignedUser.create if UnsignedUser.count < 1
