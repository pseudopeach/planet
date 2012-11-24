class Terra::ActDefend < Game::Action
  def resolve(state)
    super state
    x = Random.rand(3)
    attack = nil
    drop = nil
    if x > 0
      if attack_i = state.stacked_actions.rindex {|q| q.is_a? Terra::ActAttack}
        attack = state.stacked_actions[attack_i]
        ap = attack.xdata[:power]
        dp = player.get_game_attr(Terra::PA_ATTACK)
        drop = ap*dp/(ap+dp)
        attack.xdata[:power] -= drop
      end
      if x == 2 && attack
        state.manager.stack_action Terra::ActCounterAttack.new(self,attack.player,drop)
      end
      
    end
  end
  
end
