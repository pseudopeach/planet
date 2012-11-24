class Terra::StateManager < Game::Kernel
  
 attr_accessor :state

def begin
	resume_game
end

def add_player_observer(observer, observed, message, handler)
  #check range
  #check allowed messages
end

def remove_player_observer(observer, observed, message)
  #check range
  #check allowed messages
end

def stack_response(resp_action)
  
end


protected 

def resume_game2(new_action=nil)
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
      

    elsif action.wait_request?
      puts "*** prompt for human input"
      return #exit the game loop until we resume with the human player's move
    else
      #it's a real action, validate it
      unless action.legal_in_state? @state
        # **** log illegal action
        #really bad if played by an AI
        return
      end
      @state.stack_action action 
    end #if
  end #game loop
  @state.end_game
end #resume_game

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
			if(@state.top_stack_item && @state.turn_order_delegate.action_settled?(@state.active_action))
				@state.resolve_action
			elsif(!@state.active_action || @state.active_action && turn_order_delegate.action_settled?(@state.active_action))
				@state.record_turn_end
			end

		elsif action.wait_request?
		  puts "*** prompt for human input"
			return #exit the game loop until we resume with the human player's move
		else
			#it's a real action, validate it
			action.player = @state.active_action ? 
			   @state.turn_order_delegate.current_responder : @state.turn_order_delegate.current_turn_taker
			
			return unless action.legal_in_current_state?(@state)
			
			#stack the action
			@state.stack_action(action)
		end #if
	end #game loop
	@state.end_game
end #resume_game

end #class
