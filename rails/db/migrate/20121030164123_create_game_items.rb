class CreateGameItems < ActiveRecord::Migration
  def change
    create_table :game_items do |t|

      t.timestamps
    end
  end
end
