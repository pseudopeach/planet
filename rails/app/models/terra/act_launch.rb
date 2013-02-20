class Terra::ActLaunch < Game::Action 
  
  xdata_attr :location
  xdata_attr :created_player
 
def self.from_prototype(player, prototype_id, location)
  self.player = player
  self.target_player = prototype
  self.location = location
end

def on_stack(state)
  #charge launch points
  self.player.item_count_add Terra::FUEL_PTS, -self.target_player.launch_cost
  self.location.announce_local_activity self
end

def resolve(state)
  self.created_player = state.spawn_player_at(self.target_player, self.player, self.location)
  self.xdata[:created_player_class] = created_player.class.to_s
  self.location.announce_local_activity self
  super state
end

def legal?(state)
  return false unless super
  unless player.game.id == state.id
    @legality_error="Player must be part of current game." 
    return false
  end
  if player.creature_player?
    @legality_error="Creatures can't launch other creatures." 
    return false
  end
  unless target_player.user_id == player.user_id
    @legality_error="Prototype must be owned by the same user as the owner player."
    return false
  end
  unless target_player.prototype
    @legality_error="Can't launch experimental creature."
    return false
  end
  unless location.game.id == state.id
    @legality_error="Location is invalid."
    return false 
  end
  unless player.item_count(Terra::FUEL_PTS) >= target_player.launch_cost
    @legality_error="Owner doesn't have enough fuel points."
    return false
  end
    
  @legality_error = nil if @legality_error
  return true  
end

end