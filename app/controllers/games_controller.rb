# frozen_string_literal: true

# Pages Controller
class GamesController < ApplicationController
  def index
    # landing
    @games = Game.all
  end

  def new
    # new game form
    @game = Game.new
  end

  def create
    # deal cards
    # store hands in redis store
    @game = Game.new(game_params)

    if @game.save
      flash[:notice] = 'game added!'
      redirect_to @game
    else
      flash[:error] = 'Failed to add game!'
      render :new
    end
  end

  def show
    # show current hand

    # session[:player_hands] = []
    # session[:discarded_cards] = []
    # session[:card_deck] = []
    # session[:cards_dealt] = false

    @game = Game.find(params[:id])
    session[:current_game_id] = params[:id]
    session[:current_player_number] = 0
    @player_hands = session[:player_hands] || []
    # Rails.logger.debug("Player Hands")
    # Rails.logger.debug(@player_hands.to_yaml)
    @discarded_cards = session[:discarded_cards] || []
    # Rails.logger.debug("discarded_cards")
    # Rails.logger.debug(@discarded_cards.to_yaml)
    @card_deck = session[:card_deck] || []
    # Rails.logger.debug("card_deck")
    # Rails.logger.debug(@card_deck.to_yaml)
    @cards_dealt = session[:cards_dealt] || false
    # Rails.logger.debug("cards_dealt")
    # Rails.logger.debug(@cards_dealt)
  end

  def update
    # store current game state
  end

  # we used strong parameters for the validation of params
  def game_params
    params.require(:game).permit(:player_count)
  end
end
