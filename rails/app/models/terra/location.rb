class Terra::Location < Game::Location
  belongs_to :game, :class_name=>"Terra::GameState", :foreign_key=>"state_id", :inverse_of=>:locations
  
  include Util::Hashtastic
  hash_exclude :state_id
  
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
      vac_cap = Terra::DEF_PA_CAPACITY - hp_sum + pl.game_attr(Terra::PA_HIT_POINTS)
      pl.game_attrs = {Terra::PA_CAPACITY=>(eq_cap > vac_cap ? eq_cap : vac_cap)}
    end
  end
  
  def announce_local_activity(action)
  #notify followers of player
    in_range = []
    if action.player.creature_player?
      r_observable = action.player.game_attr Terra::PA_OBSERVABLE_RANGE
    else
      r_observable = action.target_player.game_attr Terra::PA_OBSERVABLE_RANGE
    end
    self.nearby_locations(r_observable,true).each do |loc|
      range = self.range_to(loc)
      loc.players.each do |pl|
        if pl.respond_to?(:on_creature_presence) && pl.id != action.player.id
          r_observe = pl.game_attr Terra::PA_OBSERVATION_RANGE
          if r_observe >= range
            pl.on_creature_presence action #trigger the enemy move handler of all enemies that have one and are close enough to observe
            in_range << pl
          end
        end
      end
    end
    
    #unregister observers that are no longer in range
    unreg = action.player.observing_players - in_range
    unreg.each do |q|
      state.remove_player_observer q.observer, action.player
    end
  end
end
