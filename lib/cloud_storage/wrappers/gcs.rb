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
        @bucket_name = options.delete(:bucket)

        @anonymous = options.delete(:anonymous)
        @options = options
      end

      class Files
        include Enumerable

        def initialize(list, uri)
          @list = list
          @uri = uri
        end

        def each
          return to_enum unless block_given?

          # https://googleapis.dev/ruby/google-cloud-storage/latest/Google/Cloud/Storage/Bucket.html#files-instance_method
          # https://googleapis.dev/ruby/google-cloud-storage/latest/Google/Cloud/Storage/File/List.html#all-instance_method
          @list.all { |item| yield Objects::Gcs.new(item, uri: @uri) }
        end
      end

      def files(**opts)
        Files.new bucket.files(**opts), uri
      rescue ObjectNotFound
        []
      end

      def exist?(key)
        !bucket.file(key).nil?
      rescue ObjectNotFound
        false
      end

      def upload_file(key:, file:, **opts)
        Objects::Gcs.new \
          bucket.create_file(file.path, key, **opts),
          uri: uri
      end

      def find(key)
        raise ObjectNotFound, key if (obj = bucket.file(key)).nil?

        Objects::Gcs.new(obj, uri: uri)
      end

      def delete_files(keys)
        keys.each do |key|
          bucket.file(key, skip_lookup: true).delete
        rescue ObjectNotFound, Google::Cloud::NotFoundError
        end
      end

      private

      def uri
        return @uri if defined?(@uri)
        return @uri = nil if (endpoint = options[:endpoint]).nil?

        @uri = URI.parse(endpoint).tap { |uri| uri.path = "/#{bucket.id}" }
      end

      def storage
        @storage ||=
          if @anonymous
            Google::Cloud::Storage.anonymous(**options)
          else
            Google::Cloud::Storage.new(**options)
          end
      end

      # storage.bucket(name, skip_lookup: true) makes using library very hard,
      # almost impossible
      def bucket
        @bucket ||= build_bucket
      end

      def build_bucket
        bucket = storage.bucket(@bucket_name)
        raise ObjectNotFound, @bucket_name unless bucket

        bucket
      end
    end
  end
end
