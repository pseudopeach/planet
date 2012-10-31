class Game::Player < ActiveRecord::Base

include Util::EventBroadcaster

belongs_to :game, :class_name=>"Game::State"
has_many :actions, :class_name=>"Game::Action"
has_many :items
belongs_to :user

def initialize
  super
  broadcastable :prompt
end

def human?
  return !user_id.nil?
end

def prompt(state)
	e = {:obj=>self}
	broadcast_event :prompt, e
	return new game_action(true)
end
  
attr_accessor :xdata
before_save :serialize_data
after_initialize :deserialize_data 
protected
def serialize_data
  self.data = @xdata.to_json
end
def deserialize_data
  @xdata = self.data ? JSON(self.data) : {}
end

end
