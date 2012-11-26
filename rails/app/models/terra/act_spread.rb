class Terra::ActSpread < Game::Action
  
  #location: i,j
  #game state id
  
  def resolve(state)
    super state
    
    player.preload_game_attrs [Terra::PA_GROWTH, Terra::PA_CAPACITY, Terra::PA_INVADE, Terra::PA_HIT_POINTS]
    g = player.game_attr Terra::PA_GROWTH
    cap = player.game_attr Terra::PA_CAPACITY
    cap = Terra::DEF_CAPACITY unless cap
    hp = player.game_attr Terra::PA_HIT_POINTS
    player.game_attr_add Terra::PA_HIT_POINTS, g*hp*(cap-hp)
    
    player.nearby_locations.each do |q|
      if !q.has_player_type?(self.prototype_player_id) && Random.rand() * hp/Terra::DEF_CAPACITY > (1-1/Terra::DEF_SPREAD_ODDS)
        state.spawn_player_at(player,q)
      end
    end #location loop
  end
  
end
