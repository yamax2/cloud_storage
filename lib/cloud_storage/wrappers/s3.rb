# frozen_string_literal: true

require 'aws-sdk-s3'
require 'cloud_storage/objects/s3'

module CloudStorage
  module Wrappers
    class S3 < Base
      def initialize(opts = {})
        super
        options = opts.dup

        @bucket_name = options.delete(:bucket)
        @options = options
      end

      class Files
        include Enumerable

        def initialize(client, resource, bucket_name, **opts)
          @client = client
          @resource = resource
          @bucket_name = bucket_name
          @opts = opts
        end

        def each
          return to_enum unless block_given?

          @client.list_objects(bucket: @bucket_name, **@opts).contents.each do |item|
            yield Objects::S3.new \
              item,
              bucket_name: @bucket_name,
              resource: @resource,
              client: @client
          end
        end
      end

      def files(**opts)
        Files.new(client, resource, @bucket_name, **opts)
      end

      def exist?(key)
        resource.bucket(@bucket_name).object(key).exists?
      end

      def upload_file(key:, file:, **opts)
        obj = resource.bucket(@bucket_name).object(key)

        return unless obj.upload_file(file.path, **opts)

        Objects::S3.new \
          obj,
          bucket_name: @bucket_name,
          resource: resource,
          client: client
      end

      def find(key)
        obj = resource.bucket(@bucket_name).object(key)

        raise ObjectNotFound, key unless obj.exists?

        Objects::S3.new \
          obj,
          bucket_name: @bucket_name,
          resource: resource,
          client: client
      end

      private

      def client
        @client ||= Aws::S3::Client.new(@options)
      end

      def resource
        @resource ||= Aws::S3::Resource.new(@options)
      end
    end
  end
end
