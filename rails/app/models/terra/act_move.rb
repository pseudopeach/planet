class Terra::ActMove < Game::Action
  
  def resolve(state)
    super state
    player.location = Terra::Location.find_by_id(@xdata[:new_loc_id])
    
      player.save
      player.location.announce_local_activity self
    
   
  end
  
  
end
