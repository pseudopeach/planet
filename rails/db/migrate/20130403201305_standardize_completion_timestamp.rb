class StandardizeCompletionTimestamp < ActiveRecord::Migration
  def up
    add_column :game_turn_completions, :created_at, :timestamp, :null=>false
    Game::TurnCompletion.all.each do |tc|
      tc.created_at = tc.timestamp + 4.hours
      tc.save
    end
    remove_column :game_turn_completions, :timestamp
  end

  def down
    add_column :game_turn_completions, :timestamp, :timestamp, :null=>false
    Game::TurnCompletion.all.each do |tc|
      tc.created_at = tc.timestamp - 4.hours
      tc.save
    end
    remove_column :game_turn_completions, :created_at
  end
end
