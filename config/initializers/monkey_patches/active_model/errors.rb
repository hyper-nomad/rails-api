module ActiveModel
  class Errors
    def full_message_with_redish(attribute, message)
      return message if attribute == :user_messages
      full_message_without_redish attribute, message
    end

    alias_method_chain :full_message, :redish
  end
end
