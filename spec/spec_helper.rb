# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'
SimpleCov.start do
  minimum_coverage 95.0
  add_filter 'spec/'

  add_group 'Lib', 'lib'
end

require 'pry-byebug'
require 'webmock'

require 'cloud_storage'
require 'cloud_storage/wrappers/gcs'
require 'cloud_storage/wrappers/s3'

require_relative 'rspec_helpers/s3'
require_relative 'rspec_helpers/gcs'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include RSpecHelpers::Gcs
  config.include RSpecHelpers::S3
end

WebMock.enable!
WebMock.disable_net_connect!(allow: %w[s3:9000 gcs:8080], allow_localhost: true)
