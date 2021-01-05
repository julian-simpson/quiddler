# frozen_string_literal: true

# Game Reflex
class GameReflex < ApplicationReflex
  include GameHelper
  def deal
    Rails.logger.debug('Deal')
    game_id = session[:current_game_id]
    game_play = Rails.cache.read("games/#{game_id}/game_play")

    # deal 3 cards to start round 1, 4 cards to start round 2 etc
    (3 + (game_play[:round] - 1)).times do
      game_play[:players].each_with_index do |_, index|
        (game_play[:players][index][:hand] ||= []).push(game_play[:card_deck].first)
        game_play[:card_deck].shift
      end
    end
    game_play[:discarded_cards].push(game_play[:card_deck].first)
    game_play[:card_deck].shift

    game_play[:cards_dealt] = true
    Rails.cache.write("games/#{game_id}/game_play", game_play)

    # morph the board partials for each player
    game_play[:players].each_with_index do |player, index|
      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].morph(
        selector: '#current-player-hand',
        html: render_player_hand(game_play, index)
      )

      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].morph(
        selector: '#discard-landing',
        html: render_discard_pile(game_play, index)
      )

      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].morph(
        selector: '#player-area',
        html: render_player_area(game_play, index)
      )

      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].morph(
        selector: '#card-deck',
        html: render_card_deck(game_play, index)
      )

      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].broadcast
    end
    morph :nothing
  end

  def pick_up_from_deck
    Rails.logger.debug('Pick up from deck')
    game_id = session[:current_game_id]
    game_play = Rails.cache.read("games/#{game_id}/game_play")

    game_play[:players][session[:current_player_index]][:hand].push(game_play[:card_deck].first)
    game_play[:card_deck].shift
    game_play[:turn_has_picked_up] = true

    # redraw the player hand with new card
    cable_ready["game:#{session[:current_game_id]}:session:#{session.id}"].morph(
      selector: '#current-player-hand',
      html: render_player_hand(game_play, session[:current_player_index])
    )

    # redraw the card deck with pickup action disabled
    cable_ready["game:#{session[:current_game_id]}:session:#{session.id}"].morph(
      selector: '#card-deck',
      html: render_card_deck(game_play, session[:current_player_index])
    )

    # redraw discard pile with pickup disabled
    cable_ready["game:#{game_id}:session:#{session.id}"].morph(
      selector: '#discard-landing',
      html: render_discard_pile(game_play, session[:current_player_index])
    )

    Rails.cache.write("games/#{game_id}/game_play", game_play)
    cable_ready["game:#{game_id}:session:#{session.id}"].broadcast
  end

  def drag_from_discard_pile
    Rails.logger.debug('Drag from discard pile')
    game_id = session[:current_game_id]
    game_play = Rails.cache.read("games/#{game_id}/game_play")
    current_player_index = session[:current_player_index]

    game_play[:players][session[:current_player_index]][:hand].push(game_play[:discarded_cards].last)
    game_play[:discarded_cards].pop
    game_play[:turn_has_picked_up] = true
    sorted_card_ids = JSON.parse(element.dataset.cards)

    game_play[:players][current_player_index][:hand] = game_play[:players][current_player_index][:hand]
                                                       .sort_by { |card| sorted_card_ids.index card['id'].to_s }
    Rails.cache.write("games/#{game_id}/game_play", game_play)

    game_play[:players].each_with_index do |player, index|
      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].morph(
        selector: '#discard-landing',
        html: render_discard_pile(game_play, index)
      )
      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].morph(
        selector: '#card-deck',
        html: render_card_deck(game_play, index)
      )

      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].broadcast
    end
  end

  def pick_up_discard_pile
    game_id = session[:current_game_id]
    game_play = Rails.cache.read("games/#{game_id}/game_play")

    game_play[:players][session[:current_player_index]][:hand].push(game_play[:discarded_cards].last)
    game_play[:discarded_cards].pop
    game_play[:turn_has_picked_up] = true

    Rails.cache.write("games/#{game_id}/game_play", game_play)

    game_play[:players].each_with_index do |player, index|
      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].morph(
        selector: '#discard-landing',
        html: render_discard_pile(game_play, index)
      )
      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].morph(
        selector: '#card-deck',
        html: render_card_deck(game_play, index)
      )

      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].broadcast
    end
  end

  def sort_hand
    game_id = session[:current_game_id]
    game_play = Rails.cache.read("games/#{game_id}/game_play")
    current_player_index = session[:current_player_index]

    sorted_card_ids = JSON.parse(element.dataset.cards)

    game_play[:players][current_player_index][:hand] = game_play[:players][current_player_index][:hand]
                                                       .sort_by { |card| sorted_card_ids.index card[:id].to_s }
    # redraw the player hand with new card
    cable_ready["game:#{session[:current_game_id]}:session:#{session.id}"].morph(
      selector: '#current-player-hand',
      html: render_player_hand(game_play, current_player_index)
    )
    Rails.cache.write("games/#{game_id}/game_play", game_play)
    cable_ready["game:#{game_id}:session:#{session.id}"].broadcast
  end

  def discard
    Rails.logger.debug('Discard reflex called')
    game_id = session[:current_game_id]
    game_play = Rails.cache.read("games/#{game_id}/game_play")
    current_player_index = session[:current_player_index]

    card_id = element.dataset['card-id']
    card_index = game_play[:players][current_player_index][:hand].index { |card| card[:id].to_i == card_id.to_i }
    game_play[:discarded_cards].push game_play[:players][current_player_index][:hand].delete_at(card_index)

    if game_play[:player_turn_index] == game_play[:players].length - 1
      game_play[:player_turn_index] = 0
    else
      game_play[:player_turn_index] += 1
    end
    game_play[:turn_has_picked_up] = false

    Rails.cache.write("games/#{game_id}/game_play", game_play)

    game_play[:players].each_with_index do |player, index|
      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].morph(
        selector: '#current-player-hand',
        html: render_player_hand(game_play, index)
      )

      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].morph(
        selector: '#discard-landing',
        html: render_discard_pile(game_play, index)
      )

      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].morph(
        selector: '#player-area',
        html: render_player_area(game_play, index)
      )

      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].morph(
        selector: '#card-deck',
        html: render_card_deck(game_play, index)
      )

      cable_ready["game:#{game_id}:session:#{player[:session_id]}"].broadcast
    end
  end
end
