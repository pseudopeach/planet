class Terra::GameState < Game::State
  
after_initialize :setup

has_many :player_observers, :through=> :players
has_many :locations, :foreign_key=>"state_id"
#has_many :real_players, :class_name=>"Game::Player", :foreign_key=>"state_id", :conditions=>["parent_player_id IS NULL"]
#has_many :all_players

def setup
  @turn_order_delegate = self
  @end_game_delegate = self
  #broadcast_event Game::GAME_INITIALIZED, {}
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
  players_all = self.players
  last_player = players_all.last
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
  end
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
  player.game_attr_add Terra::PA_HIT_POINTS, -Terra::PA_HUNGER
  
  #player either dies or gets a new turn
  if player.game_attr Terra::PA_HIT_POINTS < 0
    stack_action Terra::ActKill.new(player,player)
  else
    player.game_attrs = {Terra::PA_MOVES_LEFT=>player.game_attr(Terra::PA_MOVEMENT)}
  end
  self.current_turn_taker = player.next_player
  self.save
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

def spawn_player_at(player, owner_player=nil, offspring_loc=nil) # **** redo
  offspring_loc = player.location unless offspring_loc
  #clone from prototype or parent
  new_player = player.dup
  if player.owner_player
    #it's the offspring of an active player
    before = player
  else
    #it's arriving from a launch action
    #find last creature owned by this player
    player.owner_player = owner_player
    before = owner.child_creatures.last
    before = owner_player unless before
    
    new_player.state = offspring_loc.state
  end
  
  #insert into turn order
  new_player.next_player = before.next_player
  before.next_player = new_player
  
  attrs = {}
  #copy prototype attributes
  player.player_attributes.each {|r| attrs[q.name]=q.value}
  attrs[Terra::PA_HIT_POINTS] = flora? ? 1.0 : (get_game_attr Terra::PA_SIZE)
  attrs[Terra::PA_MOVES_LEFT] = new_player.game_attr Terra::PA_MOVEMENT
  attrs[Terra::PA_REPRO_PROG] = 0
  new_player.transaction do
    new_player.save
    before.save
    new_player.game_attrs = attrs
    new_player.on_born
  end
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
  #remove from turn chain
  player.transaction do
    player.prev_player.next_player = player.next_player
    player.prev_player.save
    player.next_player = nil
    player.save 
  end
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

def create_locations
  self.transaction do
  (0...10).each do |i|
    (0...10).each do |j|
      self.locations << Terra::Location.new(:i=>i,:j=>j)
    end
  end
  end
end

protected 

def broadcast_player_event(status, action)
  res_only = status == Game::ACTION_RESOLVED
  #observers = player_observers.where(:player=>action.player, :message=>action.class, :for_resolution=>res_only)
  observers = player_observers.select{|o| o.player_id==action.player_id && o.message==action.class.to_s && o.for_resolution==res_only}
  observers.each do |q|
    q.observer.send(q.handler,action)
  end
  if action.target_player
    #targets = player_observers.where(:player=>nil, :observer=>action.target_player, :message=>action.class)
    targets = player_observers.select{|o| !o.player && o.observer_id==action.target_player_id && o.message==action.class.to_s}
    targets.each do |q|
      q.observer.send(q.handler,action) #if the target player has any handlers for being targeted
    end
  end
 
end

def setup_player_order
  last_player = nil
  self.transaction do
    self.real_players.each do |rp|
      last_player.next_player = rp
      last_player.save
      last_player = rp
      rp.owned_creatures.each do |c|
        last_player.next_player = c
        last_player.save
        last_player = c
      end
    end
  end
  last_player.next_player = self.real_players.first
  last_player.save
end

def game_winner
  # **** todo
end
def end_game
  super
  #do terra specific game end stuff
end

def real_players
  self.players.select {|p| !p.owner_player_id}
end
  
end
