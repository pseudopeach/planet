package com.apptinic.turnbased.foundation

class game_action
	
#public static const wait_for_human = "wait_for_human"
	





#adds user to the list of players that have decided not to respond to this action
def list_player_as_passed(p)
	return _passed_on_by.push(p)
end
def clear_pass_list = new arrayend
def passed_on_by _passed_on_byend


def has_resolved _has_resolvedend

def game_action(wait=false)
	this.is_wait_request = wait
end

def legal_in_current_state?(state)
	return true
end

def resolve(state)
	#action does whatever it does, operating on the game state
	_has_resolved = true
end

}}endend
