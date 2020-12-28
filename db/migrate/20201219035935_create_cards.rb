# frozen_string_literal: true

# Create Cards
class CreateCards < ActiveRecord::Migration[6.1]
  def change
    create_table :cards do |t|
      t.string :letters
      t.integer :value
      t.timestamps
    end
  end
end
