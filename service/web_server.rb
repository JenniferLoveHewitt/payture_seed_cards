# frozen_string_literal: true

require File.expand_path(File.join(__FILE__, %w[.. .. environment.rb]))

# service/web_server.rb
class WebServer < Sinatra::Base
  register Sinatra::ConfigFile

  config_file File.expand_path(File.join(__FILE__, %w[.. .. config config.yml]))

  get '/api/cards' do
    if Card.count.zero? || params[:reset] == 'true'
      InitializeDatabaseService.call(settings)
    end

    json cards: Card.all
  end
end

WebServer.run!
