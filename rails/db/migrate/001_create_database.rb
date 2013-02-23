class CreateMigration < ActiveRecord::Migration
  def self.up

  create_table "actions_states_stacked", :id => false, :force => true do |t|
    t.integer "action_id", :null => false
    t.integer "state_id",  :null => false
  end

  create_table "game_actions", :force => true do |t|
    t.integer   "player_id",                       :null => false
    t.integer   "target_player_id"
    t.string    "data",             :limit => 512
    t.string    "type",             :limit => 64,  :null => false
    t.timestamp "created_at"
    t.timestamp "resolved_at"
  end

  create_table "game_item_types", :force => true do |t|
    t.string "name",            :limit => 128,                  :null => false
    t.float  "created_count",                  :default => 0.0, :null => false
    t.float  "destroyed_count",                :default => 0.0, :null => false
  end

  create_table "game_items", :force => true do |t|
    t.integer "item_type_id"
    t.float   "item_qty",     :default => 1.0, :null => false
    t.integer "player_id"
    t.integer "user_id"
  end

  create_table "game_locations", :force => true do |t|
    t.integer "i",                           :null => false
    t.integer "j",                           :null => false
    t.boolean "is_land",  :default => false, :null => false
    t.integer "state_id",                    :null => false
  end

  add_index "game_locations", ["state_id", "i", "j"], :name => "up_i_j_game", :unique => true

  create_table "game_player_attr_entries", :force => true do |t|
    t.integer "player_attribute_id", :null => false
    t.integer "action_id",           :null => false
    t.float   "value"
  end

  add_index "game_player_attr_entries", ["player_attribute_id"], :name => "player_attribute_id"

  create_table "game_player_attributes", :force => true do |t|
    t.integer "player_id",               :null => false
    t.string  "name",      :limit => 32, :null => false
    t.float   "value"
  end

  add_index "game_player_attributes", ["player_id", "name"], :name => "uk_key_per_player", :unique => true

  create_table "game_players", :force => true do |t|
    t.integer "user_id"
    t.integer "state_id"
    t.integer "next_player_id"
    t.integer "owner_player_id"
    t.string  "name",                :limit => 64,                             :null => false
    t.integer "prototype_player_id"
    t.float   "engineering_cost"
    t.float   "launch_cost"
    t.integer "location_id"
    t.text    "data"
    t.string  "type",                :limit => 64, :default => "Game::Player", :null => false
  end

  create_table "game_states", :force => true do |t|
    t.string    "status",                :limit => 32, :default => "initialized", :null => false
    t.integer   "resolving_action_id"
    t.timestamp "created_at"
    t.timestamp "last_action_at"
    t.integer   "current_turn_taker_id"
  end

  create_table "game_turn_completions", :force => true do |t|
    t.integer   "state_id",  :null => false
    t.integer   "player_id", :null => false
    t.timestamp "timestamp", :null => false
  end

  add_index "game_turn_completions", ["state_id"], :name => "state_id"

  create_table "terra_base_creatures", :force => true do |t|
    t.float  "engineering_cost",                     :default => 0.0, :null => false
    t.float  "launch_cost",                          :default => 0.0, :null => false
    t.string "name",             :limit => 32,                        :null => false
    t.string "player_class",     :limit => 64,                        :null => false
    t.text   "data",             :limit => 16777215
  end

  create_table "terra_creature_attributes", :force => true do |t|
    t.integer "crupgrade_id",                                      :null => false
    t.string  "name",             :limit => 64,                    :null => false
    t.float   "value",                                             :null => false
    t.boolean "of_base_creature",               :default => false, :null => false
  end

  add_index "terra_creature_attributes", ["crupgrade_id", "of_base_creature", "name"], :name => "uk_key_per_crupgrade", :unique => true

  create_table "terra_creature_upgrades", :force => true do |t|
    t.string "name",             :limit => 32,                  :null => false
    t.float  "engineering_cost",               :default => 0.0, :null => false
    t.float  "launch_cost",                    :default => 0.0, :null => false
  end

  create_table "terra_player_observers", :force => true do |t|
    t.integer "player_id"
    t.integer "observer_id"
    t.string  "action_type",    :limit => 64,                   :null => false
    t.string  "handler",        :limit => 64,                   :null => false
    t.boolean "for_resolution",               :default => true, :null => false
  end

  create_table "users", :force => true do |t|
    t.string    "screen_name",       :limit => 64,                     :null => false
    t.string    "email",             :limit => 320
    t.boolean   "is_disabled",                      :default => false, :null => false
    t.text      "prefs"
    t.string    "password",          :limit => 128,                    :null => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "emailverified",     :limit => 1,   :default => 0,     :null => false
    t.string    "verification_code", :limit => 35
  end

  add_index "users", ["screen_name"], :name => "screen_name", :unique => true


  end
  
  def self.down
    
  end
end