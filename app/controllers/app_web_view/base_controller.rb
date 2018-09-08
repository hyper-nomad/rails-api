module AppWebView
  class BaseController < ApplicationController
    before_action :get_user

    layout 'app_web_view'

    private

    def get_user
      @current_user ||= RedishOAuth.authenticated_user params[:redish_access_token]
    end
  end
end
