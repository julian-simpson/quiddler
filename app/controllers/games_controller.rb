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
    @game_id = params[:id]
    game = Game.find(@game_id)
    
    # Rails.cache.write("games/#{@game_id}/game_play", game.game_play_defaults)
    
    @player_count = game.player_count
    @game_play = Rails.cache.fetch("games/#{@game_id}/game_play") do
      game.game_play ? game.game_play : game.game_play_defaults
    end

    session[:current_game_id] = @game_id
    Rails.logger.debug(session[:current_game_id])
    session[:current_player_number] = 0

    Rails.logger.debug('Game Play')
    Rails.logger.debug(@game_play.to_yaml)
  end

  def update
    # store current game state
  end

  # we used strong parameters for the validation of params
  def game_params
    params.require(:game).permit(:player_count)
  end
end
