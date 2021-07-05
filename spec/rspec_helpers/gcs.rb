# frozen_string_literal: true

module RSpecHelpers
  module Gcs
    def gcs_new_client(bucket: 'some-bucket')
      CloudStorage::Client.new(
        :gcs,
        endpoint: ENV['GCS_ENDPOINT'],
        bucket: bucket,
        anonymous: true
      )
    end
  end
end
