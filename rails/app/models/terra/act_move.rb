class Terra::ActMove < Game::Action
  xdata_attr :new_location, :class_name=>"Terra::Location"
  
  def resolve(state)
    self.transaction do
      super state
      player.location = self.new_location
      
      player.save
      new_location.announce_local_activity self
    end
  end
  
  def legal?(state)
    return false unless super
    unless new_location.game.id == state.id
      @legality_error = "Location is invalid."
      return false
    end
    #unless (player.game_attr(Terra::PA_HABITAT)==Terra::HABITAT_LAND) == new_location.is_land
    #  @legality_error = "Wrong habitat."
    #  return false
    #end
    @legality_error = nil if @legality_error
    return true
  end
  
end
