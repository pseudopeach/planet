class CreateGamePlayerObservers < ActiveRecord::Migration
  def change
    create_table :game_player_observers do |t|

      t.timestamps
    end
  end
end
