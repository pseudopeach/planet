class Game::State < ActiveRecord::Base
  include Util::EventBroadcaster

attr_accessor :turn_order_delegate, :end_game_delegate
has_many :players
has_many :items, :through=>:players
has_many :turn_completions
has_and_belongs_to_many :stacked_actions, :class_name=>"Game::Action", :join_table=>"actions_states_stacked"
belongs_to :resolving_action, :class_name=>"Game::Action", :foreign_key=>"resolving_action_id"
  
def players=(input)
  self[:players] = input
  @turn_order_delegate.setup_player_order
end

# **** whose turn accessor?

def init
  @turn_order_delegate = Game::DefaultTurnTakerDelegate.new(self)
  @turn_order_delegate.setup_player_order
  @end_game_delegate = self
  Game::ALL_STATUSES.each {|q| broadcastable q}
  #broadcast_event Game::GAME_INITIALIZED, {}
end

def manager
  init_game
  mgr = Game::Kernel.new
  mgr.state = self
  return mgr
end

def top_stack_item
  return stacked_actions.last
end
def active_action
  return resolving_action ? resolving_action : top_stack_item
end

def stack_action(action)
  self.transaction do
    self.resolving_action = nil
    action.clear_pass_list
    stacked_actions << action ## auto-saves action and stack-linkage
    action.on_stack
    self.status = Game::ACTION_STACKED
    update_activity_time
  end
  
  e = {:obj=>action}
  broadcast_event Game::ACTION_STACKED, e
end

def resolve_action
  self.transaction do
    self.resolving_action = stacked_actions.last
    self.resolving_action.resolve(self)
    stacked_actions.delete resolving_action
    self.resolving_action.clear_pass_list
    self.status = Game::ACTION_RESOLVED
    update_activity_time
  end 
  
  e = {:obj=>resolving_action}
  broadcast_event Game::ACTION_RESOLVED, e
  return @resolving_action

end

def record_pass_action
  player = nil
  self.transaction do
    if(active_action)
      player = @turn_order_delegate.current_responder
      active_action.list_player_as_passed(player)
    else
      player = @turn_order_delegate.current_turn_taker
    end
    
    update_activity_time
  end
    
  broadcast_event Game::PLAYER_PASSED, {:obj=>player}
end

def record_turn_end
  turn_order_delegate.stack_was_resolved # ***
  player = @turn_order_delegate.current_turn_taker
  
  self.transaction do
    self.resolving_action = nil
    self.turn_completions << Game::TurnCompletion.new(:player => player)
    self.status = Game::TURN_END
    update_activity_time
  end
  broadcast_event Game::TURN_END, {:obj=>player}
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


def filtered_for(player)
  
  return self
end

def game_winner(state)
  if(@end_game_delegate)
    return @end_game_delegate.game_winner(self)
  end
  return nil
end

def end_game
  self.status = Game::GAME_OVER
  winner_ret = @end_game_delegate.game_winner(self)
  if(winner_ret.is_a? Player)
    e = {:outcome=>Game::OUTCOME_SINGLE_WINNER, :winner=>winner_ret}
  elsif(winner_ret.respond_to? :length && winner_ret.length > 1)
    e = {:outcome=>Game::OUTCOME_DRAW, :winners=>winner_ret}
  else
    raise "unknown game outcome"
  end
  update_activity_time
  
  broadcast_event Game::GAME_OVER, e if self.save
end

protected 

def player_can_respond?(player)
  return true
end


def update_activity_time
  self.last_action = 0.seconds.ago
  self.save
end
  
end
