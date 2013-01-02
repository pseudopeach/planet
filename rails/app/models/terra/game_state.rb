class Terra::GameState < Game::State
  
after_initialize :setup

has_many :player_observers, :through=> :players
has_many :locations, :foreign_key=>"state_id"
#has_many :real_players, :class_name=>"Game::Player", :foreign_key=>"state_id", :conditions=>["parent_player_id IS NULL"]
#has_many :all_players

def setup
  @turn_order_delegate = self
  @end_game_delegate = self
  players = self.players
  #broadcast_event Game::GAME_INITIALIZED, {}
end

def test_stuff
  p1 = self.real_players.first
  p2 = self.real_players.last
  u1 = p1.user
  u2 = p2.user
  p1p = u1.prototyped_creatures.first
  p2p = u2.prototyped_creatures.first
  return {:p1=>p1,:p2=>p2,:u1=>u1,:u2=>u2,:p1p=>p1p,:p2p=>p2p}
end

def manager
  unless @mgr
    setup
    @mgr = Terra::StateManager.new 
    @mgr.state = self
  end
  return @mgr
end

def self.create_game(user)
  game = Terra::GameState.new
  game.status = Game::GAME_CREATED
  player = Game::HumanPlayer.new
  player.user = user
  player.next_player = player
  player.name = user.screen_name
  self.transaction do
    game.save
    game.players << player
  end
  
  return game
end

def join(user)
  player = Game::HumanPlayer.new
  player.user = user
  #players_all = self.players
  last_player = self.players.last
  player.next_player = last_player.next_player
  last_player.next_player = player
  player.next_player = players.first
  player.name = user.screen_name
  self.current_turn_taker = player
  self.status = Game::GAME_READY_FOR_PLAY if status == Game::GAME_CREATED
  self.transaction do
    self.save
    self.players << player
    last_player.save
    self.create_locations
  end
end

def stack_action(action)
  super action
  broadcast_player_event Game::ACTION_STACKED, action
end

def resolve_action
  #players = self.players
  super
  broadcast_player_event Game::ACTION_RESOLVED, self.resolving_action
  return self.resolving_action
end

def record_turn_end
  self.transaction do
    player = self.current_turn_taker
    if player.creature_player?
      hp = player.game_attr Terra::PA_HUNGER
      player.game_attr_add Terra::PA_HIT_POINTS, -hp
    
      #player either dies or gets a new turn
      if player.game_attr(Terra::PA_HIT_POINTS) < 0
        stack_action Terra::ActKill.new(player,player)
        return false
      else
        player.game_attrs = {Terra::PA_MOVES_LEFT=>player.game_attr(Terra::PA_MOVEMENT)}
      end
    end
    #state housekeeping
    self.turn_completions << Game::TurnCompletion.new(:player => player)
    self.current_turn_taker = player.next_player
    self.resolving_action = nil
    self.status = Game::TURN_END
    update_activity_time
  end #trans
  return true
end

def record_round_end
  self.locations.each do |q|
    q.calc_caps
  end
end

def prompt_next_player
  player = current_turn_taker
  #player = active_action ? @turn_order_delegate.current_responder : @turn_order_delegate.current_turn_take
  
  player.game_attr_add Terra::PA_MOVES_LEFT, -1 if player.respond_to? :creature?
  
  broadcast_event Game::PROMPTING_PLAYER, {:obj=>player}
  return player.prompt(self.filtered_for(player))
end

def spawn_player_at(player, owner_player=nil, offspring_loc=nil) 
  offspring_loc = player.location unless offspring_loc
  #clone from prototype or parent
  new_player = player.dup
  new_player.prototype = player
  if player.owner_player
    #it's the offspring of an active player
    before = player
  else
    #it's arriving from a launch action
    new_player.owner_player = owner_player
    new_player.game = self
    #player before new_player will be last player owned by owner_player
    pl = owner_player
    while ((nxt=pl.next_player).owner_player_id != nil) do
      pl = nxt
    end
    before = pl 
  end
 
  new_player.location = offspring_loc
  #insert into turn order
  new_player.next_player = before.next_player
  before.next_player = new_player

  attrs = {}
  #copy prototype attributes
  #player.player_attributes.each {|q| attrs[q.name]=q.value}
  attrs[Terra::PA_HIT_POINTS] = player.flora? ? 1.0 : (player.game_attr Terra::PA_SIZE)
  attrs[Terra::PA_MOVES_LEFT] = new_player.game_attr Terra::PA_MOVEMENT
  attrs[Terra::PA_REPRO_PROG] = 0
  new_player.transaction do
    self.players << new_player
    before.save
    new_player.game_attrs = attrs
    new_player.on_born
  end
end

def retire_player(player)
  player.on_dying #tell the player he's about to die
  player.observers.each do |q|
    if q.respond_to? :on_lost_contact
      q.on_lost_contact player #notify everyone who is watching this player that he's going away
    end
  end
  #purge all observer records that involve him
  #player.observers.delete_all
  Terra::PlayerObserver.delete_all(["observer_id=? OR player_id=?",player.id,player.id])
  #remove from turn chain
  player.transaction do
    player.prev_player.next_player = player.next_player
    player.prev_player.save
    player.next_player = nil
    player.save 
    self.players.delete player
  end
end

def add_player_observer(observer_player, observed_player, action_type, handler, for_resoltion=true)
  new_o = Terra::PlayerObserver.new({:observed_player=>observed_player, :action_type=>action_type, 
    :handler=>handler, :for_resolution=>for_resoltion})
  observer_player.observations << new_o
end

def remove_player_observer(observer_player, observed_player, action_type=nil, for_resoltion=true)
  if !observer_player
    #remove everything that's observing player
    observed_player.observers.delete_all
  elsif !action_type
    #remove everything all connections between player and observer
    observer_player.observations.delete_all(:observed_player=>observed_player) 
  else
    #remove a specific observer   
    observed_player.observations.delete_all(:observed_player=>observed_player, :action_type=>action_type) 
  end
end

def create_locations
  self.transaction do
  (0...10).each do |i|
    (0...10).each do |j|
      self.locations << Terra::Location.new(:i=>i,:j=>j)
    end
  end
  end
end

def player_by_id(input)
  return players.find {|q| q.id==input}
end

def real_players
  self.players.select {|p| !p.owner_player_id}
end

protected 

def broadcast_player_event(status, action)
  res_only = status == Game::ACTION_RESOLVED
  observers = action.player.observers.where(:player_id=>action.player, :action_type=>action.class, :for_resolution=>res_only).
    includes(:observing_player)
  #observers = player_observers.select{|o| o.player_id==action.player_id && o.message==action.class.to_s && o.for_resolution==res_only}
  observers.each do |q|
    q.observing_player.send(q.handler,action)
  end
  if action.target_player
    targets = Terra::PlayerObserver.where(:observer_id=>action.target_player, :action_type=>action.class).
       includes(:observing_player)
    #targets = player_observers.select{|o| !o.player && o.observer_id==action.target_player_id && o.message==action.class.to_s}
    targets.each do |q|
      q.observer.send(q.handler,action) #if the target player has any handlers for being targeted
    end
  end
 
end

def game_winner
  # **** todo
end
def end_game
  super
  #do terra specific game end stuff
end
  
end
