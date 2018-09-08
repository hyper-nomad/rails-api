class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook; basic_action; end

  private
  def basic_action
    oauth_account = request.env['omniauth.auth']
    if oauth_account.present?
      # 実際にはcreateじゃイカンだろうね
      account = LoginAccount.find_or_create_by(provider: oauth_account['provider'], uid: oauth_account['uid'])
      account.set_account_info(oauth_account)
      account.save
    end

    redirect_to '/'
  end
end
