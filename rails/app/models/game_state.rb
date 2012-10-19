class GameState
  
include EventBroadcaster
	
@@Initialized = :initialized
@Prompting_Player = :prompting_player
@Player_Passed = :player_passed
@Purn_End = :turn_end
@Action_Stacked = :action_stacked
@Action_Resolved = :action_resolved
@Game_Over = :game_over

@Outcome_Single_Winner = :outcome_single_winner
@Outcome_Draw = :outcome_draw

attr_accessor :turn_order_delegate, :status
	
def players=(input)
	@players = input
	@turn_order_delegate.setup_player_order
end

def players
  return @players
end

# **** whose turn accessor?

def initialize(kernel)
	super
	@kernel = kernel
	@action_stack = []
	@resolving_action = nil
	@status = @@Initialize
  broadcast_status
end

def stack_action(action)
	@resolving_action = nil
	action.clear_pass_list
	@action_stack.push action

	@status = @@Action_Stacked
	broadcast_status
end

def top_stack_item
	return @action_stack.last
end
def active_action
	return @resolving_action ? @resolving_action : top_stack_item
end

def resolve_action
	@resolving_action = @action_stack.pop
	@resolving_action.resolve(self)
	@resolving_action.clear_pass_list
	
	@status = @@Action_Resolved
  broadcast_status
	
	return resolving_action
end

def prompt_next_player
	player = active_action ? @turn_order_delegate.current_responder : @turn_order_delegate.current_turn_taker
	
	if(player_can_respond?(player))
		broadcast_event @Prompting_Player, {:obj=>self}
		return player.prompt(self.filtered_for(player))
	else
		return nil
	end
end

def record_pass_action
	if(active_action)
		player = @turn_order_delegate.current_responder
		active_action.list_player_as_passed(player)
	else
		player = @turn_order_delegate.current_turn_taker
	end
		
	broadcast_event @Player_Passed, {:obj=>self}
end

def record_turn_end
	turn_order_delegate.stack_was_resolved
	resolving_action = nil
	
	@status = @@Turn_End
	broadcast_status
end

def filtered_for(player)
  return self
end

def game_winner(state)
  if(@end_game_delegate)
    return @end_game_delegate.game_winner(self)
  end
  return nil
end

def end_game
  @status = @Game_Over
  winner_ret = @end_game_delegate.get_game_winner(this)
  if(winner_ret.is_a? Player)
    e[:obj] = {:outcome=>@Outcome_Single_Winner, :winner=>winner_ret}
  elsif(winner_ret.respond_to? :length && winner_ret.length > 1)
    e[:obj] = {:outcome=>@Outcome_Draw, :winners=>winner_ret}
  else
    raise "unknown game outcome"
  end
  
  broadcast_event @status, e
end

protected 

def player_can_respond?(player)
	return true
end

def broadcast_status
  e = {:obj=>self}
  broadcast_event @status, e
end

end
