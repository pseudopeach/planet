class Game::ActionRequirements < ActiveRecord::Base
  #qty
  #used_up
  
  belongs_to :item_type
  belongs_to :action
end