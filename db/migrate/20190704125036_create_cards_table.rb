# frozen_string_literal: true

# 20190704125036_create_cards_table.rb
class CreateCardsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.string :number
      t.string :secure_code
      t.integer :exp_year
      t.integer :exp_month
      t.string :result
      t.jsonb :options
    end
  end
end
