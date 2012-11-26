class Terra::ActAttack < Game::Action
  
  def initialize(player=nil,target_player=nil)
    super false
    
    self.target_player = target_player
    if player
      self.player = player
      @xdata[:power] = player.game_attr Terra::PA_ATTACK
    end
  end
  
  def resolve(state)
    #return unless state.players.includedes target player #attack against retired player does nothing
    super state
    hp = target_player.get_attr Terra::PA_HIT_POINTS
 
    if target_player.flora?
      flora_meal
    elsif hp - @xdata[:power] > 0
      target_player.game_attr_add Terra::PA_HIT_POINTS, (-@xdata[:power])
    else
      #player kills and eats target_player
      self.transaction do
        fauna_meal
        state.manager.stack_action Terra::ActKill.new(self,target_player)
      end
    end
  end
  
  def flora_meal(state)
    target_hp = target_player.get_attr Terra::PA_HIT_POINTS
    yummyness = target_player.get_attr Terra::PA_YUMMY
    #nutrition = @xdata[:power] * yummyness
    
    if target_hp > @xdata[:power] 
      self.transaction do
        player.game_attr_add Terra::PA_HIT_POINTS, @xdata[:power] * yummyness
        target_player.game_attr_add Terra::PA_HIT_POINTS, -@xdata[:power] 
      end
    else
      self.transaction do
        player.game_attr_add Terra::PA_HIT_POINTS, target_hp*yummyness
        state.manager.stack_action Terra::ActKill.new(self,target_player)
      end    
    end
  end
  
  def fauna_meal
    #player = get_game_attributes {:hp=>Terra::ATTR_HIT_POINTS, }
    target_mass = target_player.get_attr Terra::PA_SIZE
    player.preload_game_attrs [Terra::PA_HIT_POINTS, Terra::PA_SIZE, Terra::PA_REPRO_PROG, Terra::PA_REPRO_CUTOFF]
    player_hp = player.game_attr Terra::PA_HIT_POINTS
    player_size = player.game_attr Terra::PA_SIZE
    cutoff = Terra::DEF_REPRO_CUTOFF unless (cutoff = player.get_attr Terra::PA_REPRO_CUTOFF)
    p_repro = target_mass*(player_hp-cutoff)/(1-cutoff)
    p_repro = 0 if p_repro < 0
    p_regen = target_mass - p_repro
    capacity = player_size - player_hp
    if p_regen > capacity
      p_repro = target_mass - capacity
      p_regen = capacity
    end
    hsh = {}
    hsh[Terra::PA_HIT_POINTS] = player_hp + p_regen
    hsh[Terra::PA_REPRO_PROG] = player.get_attr Terra::PA_REPRO_PROG + p_repro
    
    player.game_attributes = hsh  
  end
  
end
