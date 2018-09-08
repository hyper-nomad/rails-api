class AppDevice < ActiveRecord::Base
  belongs_to :user

  scope :usable, ->{ where(revoked_at: nil)}

  def revoke!
    update(revoke: true)
  end
end
