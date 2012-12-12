class Terra::ActLaunch < Game::Action
  def self.from_prototype(player, prototype_id, location_id)
    self.player = player
    self.target_player = prototype
    @xdata[:location_id] = location_id
  end
  
  def resolve(state)
    super state
    state.spawn_player_at(target_player, @xdata[:location_id])
  end
  
  def legal?
    location = Terra::Location.find_by_id(@xdata[:location_id])
    return target_player && location &&
      player.game == location.game &&
      target_player.prototype == target_player &&
      target_player.user == player.user
  end
end