class Terra::Predator < Game::Player
  
  def spawn_at(offspring_loc=self.location)
    super offspring_loc
    @state.add_player_observer self, nil, Terra::ActAttack.to_s, :attacked
  end
  
  def prompt
    case @xdata[:activity]
    when :forage
      act = create_forage_action
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
    return act
  end
  
  def on_enemy_move(action)
    enemy = action.player
    if is_dangerous?(enemy)
      @xdata[:activity] = :flee
      @xdata[:predator_id] = enemy.id
    elsif @xdata[:activity] == :forage && is_prey?(enemy)
      @xdata[:activity] = :persue
      @xdata[:prey_id] = enemy.id
      @state.add_player_observer self, enemy, Terra::ACT_MOVE, :on_prey_moved 
    end
  end
  
  def on_lost_contact(action)
    enemy = action.player
    if @xdata[:activity] == :flee && @xdata[:predator_id] == enemy.id
      @xdata[:activity] = :forage
      @xdata.delete :predator_id
    end
    if @xdata[:activity] == :persue && @xdata[:prey_id] == enemy.id
      @xdata[:activity] = :forage
      @xdata.delete :prey_id
    end
  end
  
  def on_prey_moved(e)
    @xdata[:prey_loc] = e[:new_loc]
  end
  
  def on_enemy_arrival(e)
    enemy = e[:enemy]
    if @xdata[:activity] == :persue && @xdata[:prey_id] == enemy.id
      @xdata[:activity] = :eat
    end
  end
  
  def attacked(action)
    attacker = action.player
    @state.manager.stack_action Terra::ActDefend.new(self,attacker)
    if should_flee?(attacker)
      @xdata[:activity] = :flee
      @xdata[:predator_id] = attacker.id
    else
      @xdata[:activity] = :eat
      @xdata[:prey_id] = attacker.id
    end
  end
  
  def is_prey?(enemy)
    my_size = self.get_game_attr Terra::PA_SIZE
    e_size = enemy.get_game_attr Terra::PA_SIZE
    return my_size / e_size > 0.5 
  end
  
  def is_dangerous?(enemy)
    # **** stub
  end
  
  def should_flee?(attacker)
    # **** stub
  end
  
end