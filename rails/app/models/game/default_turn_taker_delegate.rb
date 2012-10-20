class Game::DefaultTurnTakerDelegate
	
attr_accessor :state, :player_can_respond_to_self, :player_responds_to_self_after_other_players

def initialize state 
	@state = state
end

def setup_player_order(initial_turn_taker=0)
	@turn_taker_ind = initial_turn_taker
	@player_after = {}
	@state.players.inject do |last, player|
	  @player_after[last.object_id] = player
	end
	@player_after[@state.players.last.object_id] = @state.players.first
end
	
def stack_was_resolved
	@turn_taker_ind += 1
	@turn_taker_ind %= @state.players.length
end

def current_turn_taker
	return @state.players[@turn_taker_ind]
end


def current_responder
	active_action = @state.active_action
	if(active_action.passed_on_by.length == 0)
		if(@player_can_respond_to_self && !@player_responds_to_self_after_other_players)
			return active_action.player
		else
			return @player_after[active_action.player.object_id]
		end
	end
	return @player_after[active_action.passed_on_by.last.object_id]
end


def action_settled?(action)
	if(@player_can_respond_to_self)
		return action.passed_on_by.length == @state.players.length
	else
		return action.passed_on_by.length == (@state.players.length - 1)
	end
end


end
