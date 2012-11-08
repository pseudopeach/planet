class CreateGamePlayerAttributes < ActiveRecord::Migration
  def change
    create_table :game_player_attributes do |t|

      t.timestamps
    end
  end
end
