package com.apptinic.turnbased.foundation
	

class default_turn_taker_delegate
	


def state=(input)=inputend




def default_turn_taker_delegate(state)
	this.state = state
end

def setup_player_order(initial_turn_taker = 0)
	turn_taker_ind = initial_turn_taker
	for(i=1i<_state.players.lengthi += 1)
		player_after[_state.players[i_1]] = _state.players[i]
	player_after[_state.players[_state.players.length_1]] = _state.players[0]
end
	
def stack_was_resolved
	turn_taker_ind += 1
	turn_taker_ind %= _state.players.length
end
def current_turn_taker
	return _state.players[turn_taker_ind]
end


def current_responder
	active_action = _state.active_action
	if(active_action.passed_on_by.length == 0)
		if(player_can_respond_to_self && !player_responds_to_self_after_other_players)
			return _state.active_action.player
		else
			return player_after[active_action.player]
	end
	return player_after[active_action.passed_on_by[active_action.passed_on_by.length_1]]
end


def action_settled?(action)
	if(player_can_respond_to_self)
		return action.passed_on_by.length == _state.players.length
	else
		return action.passed_on_by.length == _state.players.length_1
end
	


}}endend
