class Terra::ActMove < Game::Action
  xdata_attr :new_location, :class_name=>"Terra::Location"
  
  def resolve(state)
    super state
    player.location = self.new_location
    
    player.save
    new_location.announce_local_activity self
  end
  
  def legal?(state)
    unless new_location.state == state
      @legality_error = "Location is invalid."
      return false
    end
    unless (player.game_attr Terra::PA_HABITAT==HABITAT_LAND) == new_location.is_land
      @legality_error = "Wrong habitat."
      return false
    end
  end
  
end
