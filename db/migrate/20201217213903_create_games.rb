# frozen_string_literal: true

# Create Games
class CreateGames < ActiveRecord::Migration[6.1]
  def change
    create_table :games do |t|
      t.integer :player_count, default: 1, null: false
      t.timestamps
    end
  end
end
