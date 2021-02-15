require_relative '../request/auth'

module Deribit
  module Action
    module Token
      def access_token
        token = RedisConnection.fetch_deribit_access_token
        return token if token

        response = Deribit::Request::Auth.new.call
        return unless response.success_response?

        RedisConnection.set_deribit_access_token(response.access_token, response.expire_in)
        response.access_token
      end
    end
  end
end