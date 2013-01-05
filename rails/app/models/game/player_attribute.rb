class Game::PlayerAttribute < ActiveRecord::Base
  has_many :history_entries, :class_name=>"Game::PlayerAttrEntry"
end
