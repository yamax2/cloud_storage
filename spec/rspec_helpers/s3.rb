# frozen_string_literal: true

module RSpecHelpers
  module S3
    def s3_new_client
      CloudStorage::Client.new \
        :s3,
        bucket: ENV['S3_BUCKET'],
        endpoint: ENV['S3_ENDPOINT'],
        region: 'RU',
        access_key_id: 'minioadmin',
        secret_access_key: 'minioadmin',
        force_path_style: true
    end
  end
end
