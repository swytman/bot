module Ftx
  module Message
    class BaseMessage
      attr_reader :data

      def self.call(data)
        new(data).call
      end

      def initialize(data)
        @data = data
      end

      def call
        raise 'stub!'
      end
    end
  end
end
