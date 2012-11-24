class Terra::GameState < Game::State
has_many :player_observers, :through=> :players
  

def init
  @turn_order_delegate = self
  @turn_order_delegate.setup_player_order
  @end_game_delegate = self
  Game::ALL_STATUSES.each {|q| broadcastable q}
  #broadcast_event Game::GAME_INITIALIZED, {}
end

def manager
  unless @mgr
    init_game
    @mgr = Terra::StateManager.new 
    @mgr.state = self
  end
  return @mgr
end

def stack_action(action)
  super action
  broadcast_player_event Game::ACTION_STACKED, action
end

def resolve_action
  @resolving_action = super
  broadcast_player_event Game::ACTION_RESOLVED, @resolving_action
  return @resolving_action
end

def prompt_next_player
  player = active_action ? @turn_order_delegate.current_responder : @turn_order_delegate.current_turn_taker
  
  if(player_can_respond?(player))
    broadcast_event Game::PROMPTING_PLAYER, {:obj=>player}
    return player.prompt(self.filtered_for(player))
  else
    return nil
  end
end

def end_game
  super
  #do terra specific game end stuff
end

def add_player_observer(observer, player, action_type, handler, for_resoltion=true)
  new_o = Terra::PlayerObserver.new(:observer=>observer, :player=>player, :action_type=>action_type, :for_resolution=>for_resoltion)
  new_o.player.player_observers << new_o
end

def remove_player_observer(observer, player, action_type=nil, for_resoltion=true)
  # **** 
end

protected 

def broadcast_player_event(status, action)
  res_only = status == Game::ACTION_RESOLVED
  observers = player_observers.where(:player=>action.player, :message=>action.class, :for_resolution=>res_only)
  observers.each do |q|
    q.observer.send(q.handler,action)
  end
  if action.target_player
    targets = player_observers.where(:player=>nil, :observer=>action.target_player, :message=>action.class)
    observers.each do |q|
      q.observer.send(q.handler,action) #if the target player has any handlers for being targeted
    end
  end
 
end
  
end
