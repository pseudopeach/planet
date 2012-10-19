package com.apptinic.turnbased.foundation
	





[event(name=player_move_prompt, type="com.apptinic.util.object_event")]

class player < event_dispatcher
	
static const player_move_prompt = "player_move_prompt"

	
def player(target=nil=
	super(target)
end

def prompt(state)
	e = new object_event(player_move_prompt)
	e.obj = state
	dispatch_event(e)
	return new game_action(true)
end



}}endend
