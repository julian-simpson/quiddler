class AddGamePlayToGames < ActiveRecord::Migration[6.1]
  def change
    add_column :games, :game_play, :jsonb, :null => true
  end
end
