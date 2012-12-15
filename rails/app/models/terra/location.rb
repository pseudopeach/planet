class Terra::Location < Game::Location
  
  def has_player_type?(prototype_id)
    return players.where(:prototype_id=>prototype_id).length > 0
  end
  
  def calc_caps
    inv_sum = 0
    hp_sum = 0
    players.each do |pl|
      inv_sum += pl.game_attr(Terra::PA_INVADE)
      hp_sum += pl.game_attr(Terra::PA_HIT_POINTS)
    end
    players.each do |pl|
      eq_cap = pl.game_attr(Terra::PA_INVADE)/inv_sum
      vac_cap = Terra::DEF_CAPACITY - hp_sum + pl.game_attr(Terra::PA_HIT_POINTS)
      pl.game_attrs = {Terra::PA_CAPACITY=>(eq_cap > vac_cap ? eq_cap : vac_cap)}
    end
  end
  
  def announce_local_activity(action)
  #notify followers of player
    in_range = []
    r_observable = action.player.game_attr Terra::PA_OBSERVABLE_RANGE
    r_observable = Terra::DEF_OBSERVABLE_RANGE unless r_observable
    self.nearby_locations(r_observable).each do |loc|
      range = self.range_to(loc)
      loc.players.each do |pl|
        if pl.respond_to? :on_creature_presence && pl != action.player
          r_observe = pl.game_attr Terra::PA_OBSERVATION_RANGE
          r_observe = Terra::DEF_OBSERVATION_RANGE unless r_observe
          if r_observe >= range
            pl.on_creature_presence action #trigger the enemy move handler of all enemies that have one and are close enough to observe
            in_range << pl
          end
        end
      end
    end
    
    #unregister observers that are no longer in range
    unreg = player.player_observers - in_range
    unreg.each do |q|
      state.remove_player_observer q.observer, action.player
    end
  end
end
