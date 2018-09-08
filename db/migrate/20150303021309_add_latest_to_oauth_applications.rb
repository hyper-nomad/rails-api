class AddLatestToOauthApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :latest, :string
  end
end
