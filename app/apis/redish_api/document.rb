module RedishAPI
  module Document
    def self.request_headers *keys
      {
        REDISH_ACCESS_TOKEN_KEY => {
          description: 'Redish Access Token',
          required: true
        },
        REDISH_APP_ID => {
          description: 'Redish application token for api auth',
          required: true
        }
      }.slice(*keys)
    end

    def self.redish_access_token
      "a token that is generated at sign in"
    end
    # NOTE: dbから取得するやり方も試したのですが、
    # DELETE /session すると app server を再起動するまで古いredish_access_tokenが残ってしまうので採用していません
    # def self.redish_access_token
    # user = User.where(email: 'user@example.com').first
    # user && token = Doorkeeper::AccessToken.where(resource_owner_id: user.id).first
    # token && token.token
    # rescue # db:migrate時に参照されてしまうので
    # "a token that is generated at sign in"
    # end
  end
end
