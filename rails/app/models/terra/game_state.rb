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

def record_turn_end
  player = @turn_order_delegate.current_turn_taker
  player.get_game_attr Terra::PA_HUNGER
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

def spawn_player_at(player, offspring_loc=nil) # **** redo
  offspring_loc = player.location unless offspring_loc
  new_player = player.dup
  new_player.state = offspring_loc.state
  new_player.turn_order = new_player.state.players.maximum(:turn_order) + 1 
  attrs = {}
  player.player_attributes.each {|r| attrs[q.name]=q.value}
  attrs[Terra::PA_HIT_POINTS] = flora? ? 1.0 : (get_game_attr Terra::PA_SIZE)
  new_player.transaction do
    new_player.save
    new_player.introduce_at offspring_loc
    new_player.set_game_attrs attrs
  end
  new_player.on_born
end

def retire_player(player)
  player.on_dying #tell the player he's about to die
  player.player_observers.each do |q|
    if q.respond_to? :on_lost_contact
      q.on_lost_contact player #notify everyone who is watching this player that he's going away
    end
  end
  #purge all observer records that involve him
  player.player_observers.delete_all
  self.player_observers.delete_all(:observer=>player)
  player.turn_order = nil
  player.save 
end

def add_player_observer(observer, player, action_type, handler, for_resoltion=true)
  new_o = Terra::PlayerObserver.new(:observer=>observer, :player=>player, :action_type=>action_type, :for_resolution=>for_resoltion)
  new_o.player.player_observers << new_o
end

def remove_player_observer(observer, player, action_type=nil, for_resoltion=true)
  if !observer
    #remove everything that's observing player
    player.player_observers.delete_all
  elsif !action_type
    #remove everything all connections between player and observer
    player.player_observers.delete_all(:observer=>observer, :player=>player) 
  else
    #remove a specific observer   
    player.player_observers.delete_all(:observer=>observer, :player=>player, :action_type=>action_type) 
  end
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