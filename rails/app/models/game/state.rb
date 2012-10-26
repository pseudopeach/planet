class Game::State < ActiveRecord::Base
  include Util::EventBroadcaster

attr_accessor :turn_order_delegate, :end_game_delegate
has_many :players
has_many :turn_completions
has_and_belongs_to_many :stacked_actions, :class_name=>"Game::Action", :join_table=>"actions_states_stacked"
belongs_to :resolving_action, :class_name=>"Game::Action"
  
def players=(input)
  self[:players] = input
  @turn_order_delegate.setup_player_order
end

# **** whose turn accessor?

def init
  @turn_order_delegate = Game::DefaultTurnTakerDelegate.new(self)
  @end_game_delegate = self
  Game::ALL_STATUSES.each {|q| broadcastable q}
  status = Game::GAME_INITIALIZED
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
  resolving_action = nil
  action.clear_pass_list
  stacked_actions << action ## auto-saves action and stack-linkage
  action.on_stack
  
  update_activity_time

  status = Game::ACTION_STACKED
  e = {:obj=>action}
  broadcast_event Game::ACTION_STACKED, e
end

def resolve_action
  resolving_action = stacked_actions.last
  resolving_action.resolve(self)
  stacked_actions.delete resolving_action
  resolving_action.clear_pass_list
  last_action = 0.seconds.ago
  if self.save 
    @status = Game::ACTION_RESOLVED
    e = {:obj=>resolving_action}
    broadcast_event Game::ACTION_RESOLVED, e
    return @resolving_action
  else
    return nil
  end
end

def record_pass_action
  if(active_action)
    player = @turn_order_delegate.current_responder
    active_action.list_player_as_passed(player)
  else
    player = @turn_order_delegate.current_turn_taker
  end
  
  update_activity_time
    
  broadcast_event Game::PLAYER_PASSED, {:obj=>player}
end

def record_turn_end
  turn_order_delegate.stack_was_resolved # ***
  resolving_action = nil
  player = @turn_order_delegate.current_turn_taker
  
  self.turn_completions << Game::TurnCompletion.new(:player => player)
  
  status = Game::TURN_END
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
  status = Game::GAME_OVER
  winner_ret = @end_game_delegate.game_winner(self)
  if(winner_ret.is_a? Player)
    e = {:outcome=>Game::OUTCOME_SINGLE_WINNER, :winner=>winner_ret}
  elsif(winner_ret.respond_to? :length && winner_ret.length > 1)
    e = {:outcome=>Game::OUTCOME_DRAW, :winners=>winner_ret}
  else
    raise "unknown game outcome"
  end
  
  broadcast_event Game::GAME_OVER, e if self.save
end

protected 

def player_can_respond?(player)
  return true
end


def update_activity_time
  self.last_action = 0.seconds.ago
  puts "saving last action time #{self.last_action.to_s(:short)}"
  self.save
end
  
end
