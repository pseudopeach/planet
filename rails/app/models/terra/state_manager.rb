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

def resume_game(request_action)
  #main game loop
  until @state.game_winner(@state) do
    #use the entered new_action, or prompt for an action
    if(request_action)
      action = request_action
      request_action = nil
    else
      action = @state.prompt_next_player
    end
    #process the action
    if action.pass? #player passed
      @state.record_pass_action
    elsif action.wait_request?
      return #exit the game loop until we resume with the human player's move
    else
      #it's a real action, validate it
      unless action.legal? @state
        # **** log illegal action
        #legality, at a minumum, checks to see if it's the players turn
        #really bad if played by an AI
        return
      end
      @state.stack_action action
    end #if
    begin #resolve actions until the stack is empty, or we get a wait request
      return if !@state.resolve_action 
    end while @state.top_stack_action
    @state.record_turn_end
  end #game loop
  @state.end_game
end #resume_game

end #class
