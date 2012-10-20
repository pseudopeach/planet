class CreateGameStates < ActiveRecord::Migration
  def change
    create_table :game_states do |t|

      t.timestamps
    end
  end
end
