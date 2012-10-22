class Game::Action < ActiveRecord::Base
  
belongs_to :player, :class_name=>"Game::Player"
has_and_belongs_to_many :passed_on_by, :class_name=>"Game::Player", :join_table=>'actions_players_passed'

  
def initialize(wait=false)
  super
  @is_wait_request = wait
end

#adds user to the list of players that have decided not to respond to this action
def list_player_as_passed(p)
	players_that_passed << p
end
def clear_pass_list 
  players_that_passed = []
end

def resolved?
  return !resolved_at.nil?
end

def wait_request?
  return @is_wait_request
end

def legal_in_current_state?(state)
	return true
end

def resolve state
	#action does whatever it does, operating on the game state
	resolved_at = DateTime.now
end

end
