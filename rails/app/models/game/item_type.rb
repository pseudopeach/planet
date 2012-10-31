class Game::ItemType < ActiveRecord::Base
  has_many :items
end