class Game::PlayerAttrEntry < ActiveRecord::Base
  belongs_to :action
  belongs_to :player_attribute
end