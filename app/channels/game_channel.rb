# frozen_string_literal: true

# Game Channel
class GameChannel < ApplicationCable::Channel
  def subscribed
    # individaul player stream
    stream_from "game:#{params[:game_id]}:session:#{session_id}"
    # game stream
    stream_from "game:#{params[:game_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
