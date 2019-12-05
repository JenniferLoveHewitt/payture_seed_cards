# frozen_string_literal: true

$LOAD_PATH.unshift(File.dirname(File.expand_path(__FILE__)))

require 'sinatra'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/namespace'
require 'sinatra/config_file'
require 'sinatra/json'

require 'faraday'
require 'pry'
require 'active_support/all'
require 'rake'

require './models/card'
require './service/initialize_database_service'

config_file File.expand_path(File.join(__FILE__, %w[.. config config.yml]))
set :database, settings.database_url
