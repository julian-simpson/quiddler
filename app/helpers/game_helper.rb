# frozen_string_literal: true

# Game Helper
module GameHelper
  def render_card_deck(game_play, current_player_index)
    pick_up_enabled = current_player_index == game_play[:player_turn_index] && game_play[:turn_has_picked_up] == false
    current_player_dealer = current_player_index == game_play[:dealer_index] && game_play[:cards_dealt] == false
    render partial: 'card_deck', locals: { pick_up_enabled: pick_up_enabled,
                                           current_player_dealer: current_player_dealer }
  end

  def render_discard_pile(game_play, current_player_index)
    pick_up_enabled = current_player_index == game_play[:player_turn_index] && game_play[:turn_has_picked_up] == false
    discard_enabled = current_player_index == game_play[:player_turn_index] && game_play[:turn_has_picked_up] == true
    render partial: 'discard_pile', locals: { cards: game_play[:discarded_cards],
                                              pick_up_enabled: pick_up_enabled,
                                              discard_enabled: discard_enabled }
  end

  def render_player_area(game_play, current_player_index)
    render partial: 'player_area', locals: { players: game_play[:players],
                                             current_player_index: current_player_index,
                                             player_turn_index: game_play[:player_turn_index],
                                             game_started: game_play[:cards_dealt] }
  end

  def render_player_hand(game_play, current_player_index)
    render partial: 'player_hand', locals: { cards: game_play[:players][current_player_index][:hand] || [] }
  end
end
