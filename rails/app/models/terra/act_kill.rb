class Terra::ActKill < Game::Action
  
  #target player
  
  def resolve(state)
    #removes target player from the gamestate
    super state
    state.retire_player target_player
  end
  
end
