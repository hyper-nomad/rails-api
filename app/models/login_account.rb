class LoginAccount < ActiveRecord::Base
  belongs_to :user

  validates_uniqueness_of :uid, scope: :provider

  def set_account_info(account)

    return if provider.to_s != account['provider'].to_s || uid != account['uid']

    _credentials = account['credentials']
    self.access_token = _credentials['token']
    self.access_secret = _credentials['secret']
    self.credentials = _credentials.to_json

    info = account['info']
    self.email = info['email']
    self.name = info['name']
    self.nickname = info['nickname']
    self.description = info['description'].try(:truncate, 255)
    self.image_url = info['image']
    self.raw_info = account['extra']['raw_info']
    self
  end

  def refresh!
    changed? ? save : touch
  end
end
