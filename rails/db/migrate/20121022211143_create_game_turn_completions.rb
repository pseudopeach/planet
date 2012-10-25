class CreateGameTurnCompletions < ActiveRecord::Migration
  def change
    create_table :game_turn_completions do |t|

      t.timestamps
    end
  end
end
