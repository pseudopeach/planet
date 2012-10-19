class Player
	
include EventBroadcaster

attr_accessor :name
broadcastable :prompt

def prompt state
	e = {:obj=>self}
	broadcast_event :prompt, e
	return new game_action(true)
end


end
