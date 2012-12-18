class Terra::ActLaunch < Game::Action 
  
  xdata_attr :location
 
def self.from_prototype(player, prototype_id, location)
  self.player = player
  self.target_player = prototype
  self.location = location
end

def self.game_launch(game)
  player = game.current_turn_taker
  action = Terra::ActLaunch.new
  action.player = player
  action.target_player = player.user.prototyped_creatures.first
  action.location = game.locations.first.id
  return action
end

def on_stack(state)
  #charge launch points
  self.player.item_count_add Terra::FUEL_PTS, -self.target_player.launch_cost
  player.location.announce_local_activity self
end

def self.make_a(name, str)
    define_method name.to_sym do
      puts str
    end
  end

def resolve(state)
  super state
  state.spawn_player_at(self.target_player, self.player, self.location)
  self.location.announce_local_activity self
end

def legal?(state)
  unless player.game.id == state.id
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