# frozen_string_literal: true

module CloudStorage
  module Objects
    class Gcs < Base
      def key
        @internal.name
      end

      def signed_url(**opts)
        expires = opts.delete(:expires_in)

        @internal.signed_url(expires: expires, **opts)
      end

      alias name key

      def delete!
        @internal.delete
        nil
      end

      private

      def internal_download(path)
        @internal.download(path)
      end
    end
  end
end
