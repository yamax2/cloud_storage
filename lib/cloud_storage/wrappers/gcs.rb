# frozen_string_literal: true

require 'google/cloud/storage'
require 'cloud_storage/objects/gcs'

module CloudStorage
  module Wrappers
    class Gcs < Base
      attr_reader :options

      # project_id
      # credentials
      # endpoint
      def initialize(opts = {})
        super

        options = opts.dup
        bucket = options.delete(:bucket)

        @options = options
        @bucket = storage.bucket(bucket)
      end

      class Files
        include Enumerable

        def initialize(list, uri)
          @list = list
          @uri = uri
        end

        def each
          return to_enum unless block_given?

          @list.each { |item| yield Objects::Gcs.new(item, uri: @uri) }
        end
      end

      def files(**opts)
        Files.new @bucket.files(**opts), uri
      end

      def exist?(key)
        !@bucket.file(key).nil?
      end

      def upload_file(key:, file:, **opts)
        Objects::Gcs.new \
          @bucket.create_file(file.path, key, **opts),
          uri: uri
      end

      def find(key)
        raise ObjectNotFound, key if (obj = @bucket.file(key)).nil?

        Objects::Gcs.new(obj, uri: uri)
      end

      private

      def uri
        return @uri if defined?(@uri)
        return @uri = nil if (endpoint = options[:endpoint]).nil?

        @uri = URI.parse(endpoint).tap { |uri| uri.path = "/#{@bucket.id}" }
      end

      def storage
        @storage ||=
          if options.key?(:credentials)
            Google::Cloud::Storage.new(**options)
          else
            Google::Cloud::Storage.anonymous(**options)
          end
      end
    end
  end
end
