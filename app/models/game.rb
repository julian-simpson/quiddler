# frozen_string_literal: true

# game model
class Game < ApplicationRecord
  validates :player_count, presence: true, numericality: { greater_than: 1, less_than: 9, only_integer: true }
end
