class LocationDefineTerrain < ActiveRecord::Migration
  def up
    remove_column :game_locations, :is_land
    add_column :game_locations, :data, :text, :null=>true
  end

  def down
    add_column :game_locations, :is_land, :boolean, :null=>false
    remove_column :game_locations, :data
  end
end
