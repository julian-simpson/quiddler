# frozen_string_literal: true

# Game Reflex
class GameReflex < ApplicationReflex
  def deal
    # morph :nothing
    game_id = session[:current_game_id]
    player_count = element.dataset[:player_count]
    Rails.logger.debug("games/#{game_id}/game_play")
    game_play = Rails.cache.read("games/#{game_id}/game_play")
    Rails.logger.debug("game_play")
    Rails.logger.debug(game_play)

    player_index = 0
    game_play[:card_deck].delete_if do |card|
      break if game_play[:player_hands].last.length == (3 + (game_play[:round] - 1))

      game_play[:player_hands][player_index].push(card)
      player_index += 1
      player_index = 0 if player_index >= player_count.to_i
      true
    end

    game_play[:discarded_cards].push(game_play[:card_deck].first)
    game_play[:card_deck].shift
    discard_html = render(partial: '/games/discard_pile', locals: { cards: game_play[:discarded_cards] })

    cable_ready["game:#{game_id}"].morph(
      selector: '#discard-landing',
      html: discard_html
    )

    game_play[:cards_dealt] = true
    Rails.cache.write("games/#{game_id}/game_play", game_play)
    cable_ready["game:#{session[:current_game_id]}"].broadcast
    morph :nothing
  end

  def pick_up_from_deck
    session[:player_hands][0].push(session[:card_deck].first)
    session[:card_deck].shift
  end

  def drag_from_discard_pile
    session[:player_hands][0].push(session[:discarded_cards].last)
    session[:discarded_cards].pop
    sorted_card_ids = JSON.parse(element.dataset.cards)
    session[:player_hands][0] = session[:player_hands][0].sort_by { |card| sorted_card_ids.index card['id'].to_s }
  end

  def pick_up_discard_pile
    session[:player_hands][0].push(session[:discarded_cards].last)
    session[:discarded_cards].pop
  end

  def sort_hand
    sorted_card_ids = JSON.parse(element.dataset.cards)
    session[:player_hands][0] = session[:player_hands][0].sort_by { |card| sorted_card_ids.index card['id'].to_s }
  end

  def discard
    card_id = element.dataset['card-id']
    index = session[:player_hands][0].index { |card| card['id'].to_i == card_id.to_i }
    session[:discarded_cards].push session[:player_hands][0].delete_at(index)
  end
end
