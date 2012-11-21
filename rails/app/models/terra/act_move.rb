class Terra::ActMove < Game::Action
  
  def resolve(state)
    super state
    player.loc_i = @xdata[:new_loc_i]
    player.loc_j = @xdata[:new_loc_j]
    player.save
    state.entered_loc loc_i, loc_j
    #notify followers of player
  end
  
end
