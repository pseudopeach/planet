class User < ActiveRecord::Base
  has_many :game_players, :conditions=>[:type=>"Game::HumanPlayer"]
  has_many :experimental_creatures, :class_name=>"Game::Player", :conditions=>[:turn_order=>nil,:is_prototyped=>false]
  has_many :prototyped_creatures, :class_name=>"Game::Player", :conditions=>[:turn_order=>nil,:is_prototyped=>true]
  has_many :active_creatures, :class_name=>"Game::Player", :conditions=>["turn_order IS NOT NULL"]
  has_many :buried_creatures, :class_name=>"Game::Player", :conditions=>["state_id IS NOT NULL", :turn_order=>nil]
end
