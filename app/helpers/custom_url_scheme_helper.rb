module CustomUrlSchemeHelper
  Protocol = 'redish'

  def scheme _endpoint, _params
    "#{Protocol}://#{_endpoint}?#{_params.to_param}"
  end

  # TODO: endpointは確定ではない
  def confirmation_scheme _params
    scheme :confirmation, _params
  end
end
