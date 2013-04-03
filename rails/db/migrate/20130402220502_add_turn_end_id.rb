class AddTurnEndId < ActiveRecord::Migration
  def up
    add_column :game_player_attr_entries, :turn_completion_id, :integer, :null=>true
    add_index :game_player_attr_entries, [:action_id,:turn_completion_id], :name=>:timeline_lookup
  end

  def down
    Game::PlayerAttrEntry.update_all(:action_id=>0)
    remove_index :game_player_attr_entries, [:action_id,:turn_completion_id]
    change_column :game_player_attr_entries, :action_id, :integer, :null=>false
  end
end
