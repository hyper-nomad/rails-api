class DeviseUsers::ConfirmationsController < Devise::ConfirmationsController
  layout 'app_web_view'

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    return super unless as_webview?

    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?
    @errors = resource.errors
  end

  def as_webview?
    request.path_info.match(/^\/app/) ? true : false
  end
end
