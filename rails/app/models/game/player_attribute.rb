class Game::PlayerAttribute < ActiveRecord::Base
  belongs_to :player, :inverse_of=>:player_attributes
  has_many :history_entries, :class_name=>"Game::PlayerAttrEntry", :inverse_of=>:player_attribute
  
end
