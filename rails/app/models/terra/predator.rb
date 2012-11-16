class Terra::Predator < Game::Player
  def hit_points
    return @xdata[:hp]
  end
  def size
    return @xdata[:size]
  end
  def hunger
    return @xdata[:hunger]
  end
  def attack
    return @xdata[:attack]
  end
  def defense
    return @xdata[:defense]
  end
  def repro_prog
    return @xdata[:repro_prog]
  end
  
  
  def prompt(state)
    if @xdata[:activity] == :persue
      if can_attack? @xdata[:prey_id]
        attack @xdata[:prey_id]
      else  
        #move toward @xdata[:prey_loc]
      end
    elsif @xdata[:activity] == :evade || @xdata[:activity] == :wounded
      #move toward @xdata[:safe_loc]
    else
      #random move
    end
  end
  
  def new_enemy_contact(enemies)
    enemies.each do |q|
      if @xdata[:activity] == :seek && can_eat?(q)
         @xdata[:activity] = :persue
         @xdata[:prey_id] = q[:id]
         q.add_observer self, Terra::FAUNA_MOVE, :prey_moved
      end
      if eats_me? q
        @xdata[:activity] = :evade
        q.add_observer self, Terra::FAUNA_MOVE, :predator_moved
      end
    end 
  end
  
  def attacked(attacker)
    if @xdata[:activity] == :persue && can_eat?(attacker)
      attack attacker
    elsif will_fight? attacker
      withstand attacker
    end #else continue fleeing
  end
  
  def enemy_defeated
    @xdata[:activity] = :seek
    @xdata.delete :prey_id
  end
  
  def prey_escaped
    @xdata[:activity] = :seek
    @xdata.delete :prey_id
  end
  
  def eat
    
  end
  
  def reproduce
    
  end
  
  def attacked
    
  end
  
  def dying
    
  end
  
end