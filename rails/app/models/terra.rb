module Terra
  def self.table_name_prefix
    'terra_'
  end
  
  FUEL_PTS = 1
  DNA_PTS = 2
  
  PA_ATTACK = :pa_attack #impl
  PA_DEFENSE = :pa_defense #impl
  PA_MOVEMENT = :pa_movement #impl
  PA_HUNGER = :pa_hunger  #impl
  PA_DIET = :pa_diet
  PA_HABITAT = :pa_habitat
  PA_SIZE = :pa_size  #impl
  PA_REPRO_CUTOFF = :pa_repro_cutoff  #impl
  PA_OBSERVABLE_RANGE = :pa_obvl_range  #impl
  PA_OBSERVATION_RANGE = :pa_obvn_range  #impl
  
  PA_GROWTH = :pa_growth  #impl
  PA_YUMMY = :pa_yummy  #impl
  PA_INVADE = :pa_invade #impl
  PA_CAPACITY = :pa_capacity #impl
  
  PA_HIT_POINTS = :pa_hit_points  #impl
  PA_MOVES_LEFT = :pa_moves_left #impl
  PA_REPRO_PROG = :pa_repro_prog  #impl
  
  HABITAT_LAND = 1.0
  HABITAT_WATER = 2.0
  HABITAT_BOTH = 3.0
  
  DEF_PA_REPRO_CUTOFF = 0.7  #impl
  DEF_PA_CAPACITY = 1000.0  #impl
  DEF_PA_SPREAD_ODDS = 4.0 # 1 in DEF_SPREAD_ODDS chance of spreading if at capacity
  
  DEF_PA_OBVN_RANGE = 2.0  #impl
  DEF_PA_OBVL_RANGE = 4.0  #impl
  
  #location arrival   #impl
  #charge points #impl
  #turn order
end
