class Game::TestKernel

attr_accessor :game_state_class

def turn_order_delegate= input
  @turn_order_delegate = input
  @turn_order_delegate.state = @state
end
def turn_order_delegate
  return @turn_order_delegate
end


def init_game
  @state = @game_state_class ? @game_state_class.new : GameState.new
  @turn_order_delegate = DefaultTurnTakerDelegate.new(@state) unless @turn_order_delegate
  @state.turn_order_delegate = @turn_order_delegate
  
  return @state
end


def begin
	resume_game
end

protected 

def resume_game(new_action=nil)
	#main game loop
	until @state.game_winner(@state) do
		#use the entered new_action, or prompt for an action
		if(new_action)
			action = new_action
			new_action = nil
		else
			action = @state.prompt_next_player
		end
		#process the action
		if !action #player passed
			@state.record_pass_action
			if(@state.top_stack_item && @turn_order_delegate.action_settled?(@state.active_action))
				@state.resolve_action
			elsif(!@state.active_action || @state.active_action && turn_order_delegate.action_settled?(@state.active_action))
				@state.record_turn_end
			end

		elsif action.wait_request?
			return #exit the game loop until we resume with the human player's move
		else
			#it's a real action, validate it
			action.player = @state.active_action ? @turn_order_delegate.current_responder : @turn_order_delegate.current_turn_taker
			
			return unless action.legal_in_current_state?(@state)
			
			#stack the action
			@state.stack_action(action)
		end #if
	end #game loop
	@state.end_game
end #resume_game

end #class
