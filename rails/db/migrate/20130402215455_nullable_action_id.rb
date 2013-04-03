class NullableActionId < ActiveRecord::Migration
  def up
    change_column :game_player_attr_entries, :action_id, :integer, :null=>true
  end

  def down
    Game::PlayerAttrEntry.update_all(:action_id=>0)
    change_column :game_player_attr_entries, :action_id, :integer, :null=>false
  end
end
