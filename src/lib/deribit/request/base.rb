require_relative '../../request'
require_relative '../action/token'

module Deribit
  module Request
    class Base < ::Request
      include Deribit::Action::Token
      attr_reader :params

      def initialize(params)
        @params = params
      end

      def headers
        {
          'Authorization' => "Bearer #{access_token}"
        }
      end
    end
  end
end

