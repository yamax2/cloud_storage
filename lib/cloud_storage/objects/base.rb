# frozen_string_literal: true

module CloudStorage
  module Objects
    class Base
      attr_reader :internal

      def initialize(internal)
        @internal = internal
      end

      def size
        @internal.size
      end

      def download(local_file = Tempfile.new)
        internal_download(local_file).tap(&:rewind)
      end

      def signed_url(**opts)
        raise 'not implemented'
      end

      def delete!
        raise 'not implemented'
      end

      private

      def internal_download(local_file)
        raise 'not implemented'
      end
    end
  end
end
