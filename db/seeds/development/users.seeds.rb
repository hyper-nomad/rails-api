user = SignedUser.find_or_create_by email: "user@example.com"
user.skip_confirmation!
user.update_attributes(password: 'test1234')
