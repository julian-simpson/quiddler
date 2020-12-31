# frozen_string_literal: true

# Game Reflex
class GameReflex < ApplicationReflex
  def deal
    # morph :nothing
    player_count = element.dataset[:player_count].to_i

    shuffled_deck = Card.order(Arel.sql('RANDOM()')).as_json

    player_hands = []
    player_count.times do |i|
      player_hands[i] = []
    end
    player_index = 0
    shuffled_deck.delete_if do |card|
      break if player_hands.last.length == 3

      player_hands[player_index].push(card)
      player_index += 1
      player_index = 0 if player_index >= player_count
      true
    end
    session[:discarded_cards] = []
    session[:discarded_cards].push(shuffled_deck.first)
    shuffled_deck.shift
    discard_html = render(partial: '/games/discard_pile', locals: { cards: session[:discarded_cards] })

    cable_ready["game:#{session[:current_game_id]}"].morph(
      selector: '#discard-landing',
      html: discard_html
    )

    session[:player_hands] = player_hands
    session[:card_deck] = shuffled_deck
    session[:cards_dealt] = true
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
