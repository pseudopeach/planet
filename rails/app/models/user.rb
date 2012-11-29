class User < ActiveRecord::Base
  has_many :game_players, :conditions=>[:type=>"Game::HumanPlayer"]
  has_many :experimental_creatures, :class_name=>"Game::Player", :conditions=>[:turn_order=>nil,:is_prototyped=>false]
  has_many :prototyped_creatures, :class_name=>"Game::Player", :conditions=>[:turn_order=>nil,:prototype_player_id=>:id]
  has_many :active_creatures, :class_name=>"Game::Player", :conditions=>["turn_order IS NOT NULL"]
  has_many :buried_creatures, :class_name=>"Game::Player", :conditions=>["state_id IS NOT NULL", :turn_order=>nil]
  has_many :items, :class_name=>"Game::Item"
  
  include Game::ItemAccounting

end
