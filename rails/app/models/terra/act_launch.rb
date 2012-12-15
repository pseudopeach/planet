class Terra::ActLaunch < Game::Action
 
def self.from_prototype(player, prototype_id, location_id)
  self.player = player
  self.target_player = prototype
  @xdata[:location_id] = location_id
end

def on_stack(state)
  #charge launch points
  self.player.item_count_add Terra::FUEL_TYPE, -self.target_player.launch_cost
end

def resolve(state)
  super state
  state.spawn_player_at(self.target_player, self.player, @xdata[:location_id])
end

def legal?(state)
  unless player.game == state
    @legality_error="Player must be part of current game." 
    return false
  end
  if player.creature_player?
    @legality_error="Creatures can't launch other creatures." 
    return false
  end
  unless target_player.user == player.user
    @legality_error="Prototype must be owned by the same user as the owner player."
    return false
  end
  unless target_player.prototype_player
    @legality_error="Can't launch experimental creature."
    return false
  end
  location = Terra::Location.find_by_id(@xdata[:location_id])
  unless location.game == state
    @legality_error="Location is invalid."
    return false 
  end
  unless player.item_count(Terra::FUEL_PTS,owner_player) >= target_player.launch_cost
    @legality_error="Owner doesn't have enough fuel points."
    return false
  end
    
  @legality_error = nil if @legality_error
  return true  
end

end