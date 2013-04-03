class Game::Action < ActiveRecord::Base
  
include Game::ExtendedAttributes
  
attr_accessor :is_wait_request, :is_pass_action, :legality_error, :xdata, :game
  
belongs_to :player
belongs_to :target_player, :class_name=>"Game::Player"
has_many :player_attr_entries
#has_and_belongs_to_many :passed_on_by, :class_name=>"Game::Player", :join_table=>'actions_players_passed'

#adds user to the list of players that have decided not to respond to this action
def list_player_as_passed(p)
	passed_on_by << p
end
def clear_pass_list 
  passed_on_by.clear
end

def resolved?
  return !resolved_at.nil?
end

def self.create_wait
  out = self.class.new
  out.is_wait_request = true
  return out
end
def wait_request?
  return @is_wait_request
end

def self.create_pass
  out = self.class.new
  out.is_pass_action = true
  return out
end
def pass?
  return @is_pass_action
end
def can_interrupt?
  return false
end
def uses_move?
  return true
end

def legal?(state)
  @game = state
  unless can_interrupt? || state.current_turn_taker_id == self.player_id
    legality_error = "Can't play this action on another player's turn."
    return false
  end
  if uses_move? && player.game_attr(Terra::PA_MOVES_LEFT) < 1
    legality_error = "Player doen't have any moves left."
    return false
  end
	return true
end

def on_stack(state)
  @game = state
  if uses_move?
    self.player.game_attr_add Terra::PA_MOVES_LEFT, -1
  end
  #if the action does anything the moment it hits the stack
end

def resolve(state)
  @game = state
	#action does whatever it does, operating on the game state
	self.resolved_at = 0.seconds.ago
	self.save
end

after_initialize :deserialize_data
before_save :serialize_data

def player
  if @game && out = @game.player_by_id(self.player_id)
    return out
  end
  return super
end

def target_player
  if @game && out = @game.player_by_id(self.target_player_id)
    return out
  end
  return super
end

def timestamp
  return created_at
end

end
