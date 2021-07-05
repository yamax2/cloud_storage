# frozen_string_literal: true

module CloudStorage
  module Wrappers
    class Base
      def self.inherited(subclass)
        super

        ::CloudStorage.register_wrapper(subclass)
      end

      def initialize(_opts = {}); end

      def files(**opts)
        raise 'not implemented'
      end

      def exist?(_key)
        raise 'not implemented'
      end

      def upload_file(key:, file:, **opts)
        raise 'not implemented'
      end

      def find(key)
        raise 'not implemented'
      end

      def delete_files(keys)
        raise 'not implemented'
      end
    end
  end
end
