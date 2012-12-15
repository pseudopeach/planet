class User < ActiveRecord::Base
  has_many :game_players, :conditions=>[:type=>"Game::HumanPlayer"]
  has_many :experimental_creatures, :class_name=>"Game::Player", :conditions=>["prototype_player_id IS NULL AND state_id IS NULL"]
  has_many :prototyped_creatures, :class_name=>"Game::Player", :conditions=>["prototype_player_id IS NOT NULL AND state_id IS NULL"]
  #has_many :active_creatures, :class_name=>"Game::Player", :conditions=>["turn_order IS NOT NULL AND state_id IS NOT NULL"]
  #has_many :buried_creatures, :class_name=>"Game::Player", :conditions=>["turn_order IS NULL AND state_id IS NOT NULL"]
  has_many :items, :class_name=>"Game::Item"
  
  include Game::ItemAccounting

end
