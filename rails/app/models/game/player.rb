class Game::Player < ActiveRecord::Base
	
include EventBroadcaster

attr_accessor :name
belongs_to :game, :class_name=>State, :foreign_key=>"game_id"

def initialize
  broadcastable :prompt
end

def prompt state
	e = {:obj=>self}
	broadcast_event :prompt, e
	return new game_action(true)
end


end
