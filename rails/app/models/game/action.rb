class Game::Action < ActiveRecord::Base
  
attr_accessor :name, :player
belongs_to :player
has_and_belongs_to_many :players_that_passed, :class_name=>Player, :join_table=>"actions_players_passed"

  
def initialize(wait=false)
  @passed_on_by = []
  @has_resolved = false
  @is_wait_request = wait
end

#adds user to the list of players that have decided not to respond to this action
def list_player_as_passed(p)
	return @passed_on_by.push(p)
end
def clear_pass_list 
  @passed_on_by = []
end

def resolved?
  return @has_resolved
end

def wait_request?
  return @is_wait_request
end

def legal_in_current_state?(state)
	return true
end

def resolve state
	#action does whatever it does, operating on the game state
	@has_resolved = true
end

end
