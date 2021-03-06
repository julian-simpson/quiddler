# frozen_string_literal: true

# Pages Controller
class GamesController < ApplicationController
  def index
    # landing
    @games = Game.all
    @animate = session[:animate] || false
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
    # show game

    @game_id = params[:id]

    # Rails.cache.write("games/#{@game_id}/game_play", Game.game_play_defaults)

    @game_play = Rails.cache.fetch("games/#{@game_id}/game_play") do
      game = Game.find(@game_id)
      game.game_play || Game.game_play_defaults
    end

    session[:current_game_id] = @game_id

    # look for current session in player array
    session[:current_player_index] = @game_play[:players].index { |h| h[:session_id] == session.id.to_s }

    # Rails.logger.debug('Game Play')
    # Rails.logger.debug(@game_play.to_yaml)
    return if session[:current_player_index]

    @game_play[:players].push({ session_id: session.id.to_s })
    session[:current_player_index] = @game_play[:players].length - 1
    Rails.cache.write("games/#{@game_id}/game_play", @game_play)
    # use cable ready to broadcast the new player list to each of the other players
    # (except current player who will already have the full list)
    @game_play[:players].reject { |p| p[:session_id] == session.id.to_s }.each_with_index do |player, index|
      cable_ready["game:#{@game_id}:session:#{player[:session_id]}"].morph(
        selector: '#player-area',
        html: helpers.render_player_area(@game_play, index)
      ).broadcast("game:#{@game_id}:session:#{player[:session_id]}")
    end
  end

  def update
    # store current game state
  end

  # we used strong parameters for the validation of params
  def game_params
    params.require(:game).permit(:player_count)
  end
end
