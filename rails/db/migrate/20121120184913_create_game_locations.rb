class CreateGameLocations < ActiveRecord::Migration
  def change
    create_table :game_locations do |t|

      t.timestamps
    end
  end
end
