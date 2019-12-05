# frozen_string_literal: true

# spec/spec_helper.rb
require 'rack/test'
require 'rspec'
require 'vcr'

ENV['RACK_ENV'] = 'test'

require File.expand_path(File.join(__FILE__, %w[.. .. environment.rb]))

config_file File.expand_path(File.join(__FILE__, %w[.. .. config test.yml]))
set :database, settings.database_url

connection = PG.connect(settings.database_url)
connection.exec('TRUNCATE cards;')

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :faraday
end

module RSpecMixin
  include Rack::Test::Methods

  def app
    described_class
  end
end

RSpec.configure { |c| c.include RSpecMixin }
