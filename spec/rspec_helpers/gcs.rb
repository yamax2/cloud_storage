# frozen_string_literal: true

module RSpecHelpers
  module Gcs
    def gcs_new_client
      CloudStorage::Client.new(
        :gcs,
        endpoint: ENV['GCS_ENDPOINT'],
        bucket: 'some-bucket',
        anonymous: true
      )
    end
  end
end
