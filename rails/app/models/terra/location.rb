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
end
