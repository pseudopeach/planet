class Game::Item < ActiveRecord::Base
  
  belongs_to :player
  belongs_to :user
  belongs_to :item_type
  
end
