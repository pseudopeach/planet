class Terra::ActCounterAttack < Game::Action
  
  def initialize(player=nil,target_player=nil,power=nil)
    super false
    self.player = player
    self.target_player = target_player
    @xdata[:power] = power if power
  end
  
  def resolve(state)
    #return unless state.players.includedes target player #attack against retired player does nothing
    super state
    hp = target_player.get_attr Terra::PA_HIT_POINTS
 
    if hp - @xdata[:power] > 0
      target_player.game_attr_add Terra::PA_HIT_POINTS, (-@xdata[:power])
    else
      state.manager.stack_action Terra::ActKill.new(self,target_player)
    end
  end
  
end
