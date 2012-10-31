class Game::Action < ActiveRecord::Base
  
belongs_to :player
has_and_belongs_to_many :passed_on_by, :class_name=>"Game::Player", :join_table=>'actions_players_passed'
has_many :action_requirements

  
def initialize(wait=false)
  super
  @is_wait_request = wait
end

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

def wait_request?
  return @is_wait_request
end

def legal?(state)
  inv = {}
  player.items.each do |q|
    inv[q.item_type] = qty
  end
	action_requirements.each do |q|
	  return false if inv[q.item_type].nil? || inv[q.item_type] < q.item_qty
	end
	return true
end

def on_stack
  #if the action does anything the moment it hits the stack
end

def resolve(state)
	#action does whatever it does, operating on the game state
	self.resolved_at = 0.seconds.ago
	self.save
end

end
