# frozen_string_literal: true

# game model
class Game < ApplicationRecord
  validates :player_count, presence: true, numericality: { greater_than: 1, less_than: 9, only_integer: true }
  def game_play_defaults
    game_play = {}
    game_play[:round] = 1
    # as json actually gives us an array of hashes for whatever reason... which is what we want
    game_play[:card_deck] = Card.order(Arel.sql('RANDOM()')).as_json.collect {|h|h.symbolize_keys}
    game_play[:cards_dealt] = false
    game_play[:player_turn] = 1
    game_play[:player_hands] = self.player_count.times.collect { [] }
    game_play[:discarded_cards] = []
    Rails.logger.debug(game_play)
    game_play
  end
end
