class Terra::Predator < Game::Player
  xdata_attr :prey, :class_name=>"Game::Player"
  xdata_attr :predator, :class_name=>"Game::Player"
  xdata_attr :prey, :class_name=>"Game::Player"
  xdata_attr :prey_last_location, :class_name=>"Terra::Location"
  
  
  def on_born
    super 
    game.add_player_observer self, nil, Terra::ActAttack.to_s, :attacked, false
  end
  
  def prompt
    check_prey
    case @xdata[:activity]
    when :forage
      act = self.game_attr(Terra::PA_REPRO_PROG) >= player.game_attr(Terra::PA_SIZE) ? create_birth : create_forage_action
    when :persue
      act = create_persuit_move
    when :eat
      act = create_attack_action
    when :flee
      act = create_attack_action
    else
      @xdata[:activity] = :forage
      act = create_forage_action
    end
    act = Game::Action.create_pass unless act
    return act
  end
  
  def on_creature_presence(action)
    if action.resolved? && enemy?(action.player)
      on_enemy_move(action)
    elsif action.resolved?
      on_friendly_presence(action)
    else
      on_presence_action_stacked(action)
    end 
  end
  
  def on_enemy_move(action)
    enemy = action.player
    if is_dangerous?(enemy)
      @xdata[:activity] = :flee
      self.predator = enemy
    elsif @xdata[:activity] == :forage && is_prey?(enemy)
      @xdata[:activity] = :persue
      self.prey = enemy
      @state.manager.add_player_observer self, enemy, Terra::ACT_MOVE, :on_prey_moved 
    end
    self.save
  end
  
  def on_lost_contact(action)
    enemy = action.player
    if @xdata[:activity] == :flee && predator.id == enemy.id
      @xdata[:activity] = :forage
      self.predator = nil
    end
    if @xdata[:activity] == :persue && prey.id == enemy.id
      @xdata[:activity] = :forage
      self.prey = nil
    end
    self.save
  end
  
  def on_friendly_presence(action)
  end
  
  def on_presence_action_stacked(action)
  end
  
  def on_prey_moved(action)
    prey_last_location = action.new_location
  end
  
  def check_prey(prey=nil)
    if @xdata[:activity] == :persue && prey_last_location.id == self.location.id
        @xdata[:activity] = :eat
    end
    self.save
  end
  
  def attacked(action)
    attacker = action.player
    @state.manager.stack_action Terra::ActDefend.new(self,attacker)
    if should_flee?(attacker)
      @xdata[:activity] = :flee
     self.predator = attacker
    else
      @xdata[:activity] = :eat
      self.prey = attacker
    end
    self.save
  end
  
  def is_prey?(enemy)
    my_size = self.game_attr Terra::PA_SIZE
    e_size = enemy.game_attr Terra::PA_SIZE
    return my_size / e_size > 0.5 
  end
  
  def is_dangerous?(enemy)
    return true
  end
  
  def should_flee?(attacker)
    return false
  end
  
end