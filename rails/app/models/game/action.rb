class Game::Action < ActiveRecord::Base
  
attr_accessor :is_wait_request, :is_pass_action, :legality_error, :xdata
  
belongs_to :player
belongs_to :target_player, :class_name=>"Game::Player"
has_and_belongs_to_many :passed_on_by, :class_name=>"Game::Player", :join_table=>'actions_players_passed'
has_many :action_requirements

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


def legal?(state)
  unless can_interrupt? || state.current_turn_taker == self.player
    return false
  end
	return true
end

def on_stack(state)
  #if the action does anything the moment it hits the stack
end

def resolve(state)
	#action does whatever it does, operating on the game state
	self.resolved_at = 0.seconds.ago
	self.save
end

def self.xdata_attr(name, options={})
  name_s = name.to_s
  class_name = options[:class_name] ? options[:class_name] : ("Terra::"+name_s.camelize)
  model_class = class_name.constantize
  col_name = :id # options[:column_name] ? options[:column_name] : "id"
  define_method name.to_sym do
    return @loaded_xdata[name] if @loaded_xdata[name]
    key = @xdata[name_s+"_id"]
    return nil unless key
    @loaded_xdata[name] = model_class.find_by_id(key)
    return @loaded_xdata[name]
  end
  define_method "#{name.to_s}=".to_sym do |input|
    @loaded_xdata[name] = input
    @xdata[(name_s+"_id").to_sym] = input.send col_name
  end
end

after_initialize :deserialize_data
before_save :serialize_data

def serialize_data
  self.data = @xdata.empty? ? nil : @xdata.to_json
end
def deserialize_data
  @xdata = self.data ? JSON(self.data) : {}
  @loaded_xdata = {}
end

end
