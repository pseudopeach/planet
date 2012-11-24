module Terra
  def self.table_name_prefix
    'terra_'
  end
  
  PA_ATTACK = :pa_attack
  PA_DEFENSE = :pa_defense
  PA_MOVEMENT = :pa_movement
  PA_HUNGER = :pa_hunger
  PA_DIET = :pa_diet
  PA_HABITAT = :pa_habitat
  PA_SIZE = :pa_size
  PA_REPRO_CUTOFF = :pa_repro_cutoff
  PA_OBSERVABLE_RANGE = :pa_obvl_range
  PA_OBSERVATION_RANGE = :pa_obvn_range
  
  PA_GROWTH = :pa_growth
  PA_YUMMY = :pa_yummy
  PA_INVADE = :pa_invade
  
  PA_HIT_POINTS = :pa_hit_points
  PA_MOVES_LEFT = :pa_moves_left
  PA_REPRO_PROG = :pa_repro_prog
  
  DEF_REPRO_CUTOFF = 0.7
  DEF_CAPACITY = 1000.0
  DEF_SPREAD_ODDS = 4.0 # 1 in DEF_SPREAD_ODDS chance of spreading if at capacity
  
  DEF_OBSERVATION_RANGE = 2.0
  DEF_OBSERVABLE_RANGE = 3.0
end
