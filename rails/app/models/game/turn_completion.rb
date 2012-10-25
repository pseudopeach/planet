class Game::TurnCompletion < ActiveRecord::Base
  belongs_to :player
  belongs_to :state
end
