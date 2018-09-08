class AndroidDevice < AppDevice
  def self.find_user id
    User.find(id)
  end
end
