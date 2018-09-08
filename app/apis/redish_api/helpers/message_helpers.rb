module RedishAPI
  module Helpers
    module MessageHelpers
      # ex1)
      # redish_error!(:not_found, :"error.invalid_login_info", :"info.sign_in", 'パスワードが違う。')
      # => 
      # response code: 404
      # response body:
      # {
      #   "user_messages": [
      #     "ログイン情報が間違っています。",
      #     "ログインしました。"
      #     "パスワードが違う。"
      #   ]
      # }
      #
      # ex2)
      # redish_error!(:not_found)
      # response code: 404
      # response body:
      # {
      #   "error": "Not Found"
      # }
      def redish_error! status, *message_keys
        status_code, message = I18n.t(:"#{status}", scope: :sc)
        error!(message, status_code) if message_keys.blank?
        messages = {}
        messages[:user_messages] = message_keys.map do |key|
          I18n.translate!(:"#{key}", scope: :user_messages) rescue key
        end
        error!(messages, status_code)
      end
    end
  end
end
