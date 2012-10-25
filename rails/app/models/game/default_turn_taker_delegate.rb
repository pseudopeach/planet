class Game::DefaultTurnTakerDelegate
	
attr_accessor :state, :player_can_respond_to_self, :player_responds_to_self_after_other_players

def initialize(state) 
 
	self.state = state
end

def state=(input)
  @state= input
  setup_player_order
end

def setup_player_order
  @player_list = @state.players.order("turn_order")
end
	
def stack_was_resolved
	
end

def current_turn_taker
	n = @state.turn_completions.size
	n %= @player_list.size
	return @player_list[n]
end


def current_responder
	n = @state.active_action.passed_on_by.size
	m = @player_list.index state.active_action.player
	n = (m+n) % @player_list.size
  return @player_list[n]
end


def action_settled?(action)
	if(@player_can_respond_to_self)
		return action.passed_on_by.size == @state.players.size
	else
		return action.passed_on_by.size == (@state.players.size - 1)
	end
end


end
