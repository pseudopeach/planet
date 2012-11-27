class Terra::ActBirth < Game::Action
  
  def resolve(state)
    super state
    
    player.game_attr_add(Terra::PA_REPRO_PROG, -player.game_attr(Terra::PA_SIZE))
    state.spawn_player_at(player)
  end
  
  def legal?
    return player.game_attr(Terra::PA_REPRO_PROG) >= player.game_attr(Terra::PA_SIZE)
  end
  
end
