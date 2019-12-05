# frozen_string_literal: true

require 'spec_helper.rb'

describe 'InitializeDatabaseService' do
  let(:settings) { Sinatra::Application.settings }
  let(:cards) do
    JSON.parse(
      File.read(
        File.expand_path(
          File.join(__FILE__, %w[.. .. .. db fixtures cards.json])
        )
      )
    )
  end

  it 'get cards' do
    VCR.use_cassette 'payture/cards' do
      expect(Card.count).to eq 0
      InitializeDatabaseService.call(settings)

      expect(Card.count).to eq cards.count
    end
  end
end
