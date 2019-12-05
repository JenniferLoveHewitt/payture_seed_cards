# frozen_string_literal: true

# initialize_database_service.rb
class InitializeDatabaseService
  CARD_PARAMS = %w[number exp_month exp_year secure_code options].freeze

  def self.call(*args, &block)
    new(*args, &block).call
  end

  def initialize(settings)
    @settings = settings
  end

  def call
    ActiveRecord::Base.transaction do
      Card.delete_all

      cards = JSON.parse(
        File.read(
          File.expand_path(
            File.join(__FILE__, %w[.. .. db fixtures cards.json])
          )
        )
      )

      cards.each do |_, card|
        created_card = Card.create(card)

        update_options(payture_request(created_card, 'Add'), created_card)

        next if created_card.options['card_id'].blank?

        update_options(payture_request(created_card, 'Activate'), created_card)
      end
    end
  end

  private

  def payture_conn
    Faraday.new(url: @settings.payture_endpoint) do |faraday|
      faraday.adapter Faraday.default_adapter
    end
  end

  def update_options(data, card)
    options = {
      error_code: data['ErrCode'],
      card_id: data['CardId']
    }

    card.update(options: options)
  end

  def payture_request(card, action)
    response_xml =
      payture_conn.post(
        cards_url(card.slice(*CARD_PARAMS), action)
      )

    Hash.from_xml(response_xml.body)[action]
  end

  def cards_url(data, action)
    "#{action}?VWID=#{@settings.payture_merchant_id}&" \
      "DATA=#{url_encode(data, action)}"
  end

  def url_encode(data, action)
    CGI.escape(
      params_for(data, action)
        .map { |key, val| "#{key}=#{val}" }
        .join(';') + ';'
    )
  end

  def params_for(data, action)
    params =
      case action
      when 'Add'
        {
          'CardHolder' => 'Test',
          'CardNumber' => data.fetch('number'),
          'EMonth' => data.fetch('exp_month'),
          'EYear' => data.fetch('exp_year'),
          'SecureCode' => data.fetch('secure_code')
        }
      when 'Activate'
        {
          'CardId' => data.fetch('options')[:card_id],
          'Amount' => @settings.payture_activation_amount
        }
      end

    params.merge(
      'VWUserLgn' => @settings.vm_user_login,
      'VWUserPsw' => @settings.vm_user_password
    )
  end
end
