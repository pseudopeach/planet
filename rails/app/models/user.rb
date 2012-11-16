class User < ActiveRecord::Base
  has_many :game_players, :conditions=>[:type=>"Game::HumanPlayer"]
  has_many :experimental_creatures, :class_name=>"Game::Player", :conditions=>[:turn_order=>nil,:is_prototyped=>false]
  has_many :prototyped_creatures, :class_name=>"Game::Player", :conditions=>[:turn_order=>nil,:is_prototyped=>true]
end
