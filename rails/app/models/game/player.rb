class Game::Player < ActiveRecord::Base
belongs_to :game, :class_name=>"Game::State"
has_many :actions, :class_name=>"Game::Action"
has_many :items
belongs_to :user
belongs_to :prototype, :class_name=>"Game::Player", :foreign_key=>"prototype_player_id"
belongs_to :location
has_many :player_observers
has_many :player_attributes
#has_many :upgrades

def prototype
  #charge owner dna points
  #self.prototype = self
end

def set_location(location)
  self.loc_i = location[:i]
  self.loc_j = location[:j]
end

def prompt(state)
	e = {:obj=>self}
	broadcast_event :prompt, e
	return new game_action(true)
end
  
attr_accessor :xdata
before_save :serialize_data
#after_initialize :load_broadcastables 
after_initialize :deserialize_data 

def serialize_data
  self.data = @xdata.empty? ? nil : @xdata.to_json
end
def deserialize_data
  @xdata = self.data ? JSON(self.data) : {}
end

def add_observer(observer, message, handler)
  #raise "Tried to observe non-broadcastable message." unless @broadcastable.index message
  player_observers << Game::PlayerObserver.new(:message=>message, :observer=>observer, :handler=>handler)
end

def remove_observer(observer, message)
  player_observers.destroy_all(:observer=>observer, :message=>message)
end

def remove_observer_all(observer)
  player_observers.destroy_all(:observer=>observer)
end

def broadcast_event(message, obj)
  #raise "Tried to broadcast non-broadcastable message." unless @broadcastable.index message
  obj[:message] = message
  obs = player_observers.where(:message=>message)
  obs.each do |q|
    q.observer.send(q[:handler], obj)
  end
end

def get_game_attr(name, unwrap=true)
  @loaded_game_attributes = {} unless @loaded_game_attributes
  if @loaded_game_attributes.key? name
    return @loaded_game_attributes[name]
  end
  if out = player_attributes.where(:name=>name).first
    @loaded_game_attributes[name] = out
  end
  return (unwrap && out) ? out.value : out
end

def tem_get_attr
  return @loaded_game_attributes
end

def set_game_attrs(hash_in)
  @loaded_game_attributes = {} unless @loaded_game_attributes
  self.transaction do
    hash_in.each do |key, item|
      if @loaded_game_attributes.key?(key)
        #item already loaded
        @loaded_game_attributes[key].value = item
        @loaded_game_attributes[key].save
      elsif found = player_attributes.where(:name=>key).first
        #item exists, but not already loaded
        @loaded_game_attributes[key] = found
        found.value = item
        found.save
      else
        #item needs to be created
        new_attr = Game::PlayerAttribute.new(:name=>key, :value=>item)
        player_attributes << new_attr
        @loaded_game_attributes[name] = new_attr
      end
    end #each loop
  end #transaction
      
end

def game_attr_add(name, d_value)
  @loaded_game_attributes = {} unless @loaded_game_attributes
  if @loaded_game_attributes.key?(name)
    #item already loaded
    @loaded_game_attributes[name].value += d_value
    @loaded_game_attributes[name].save
  elsif found = player_attributes.where(:name=>name).first
    #item exists, but not already loaded
    @loaded_game_attributes[name] = found
    found.value += d_value
    found.save
  else
    #item needs to be created
    new_attr = Game::PlayerAttribute.new(:name=>name, :value=>d_value)
    player_attributes << new_attr
    @loaded_game_attributes[name] = new_attr
  end
end

def spawn_at(offspring_loc=self.location)
  new_player = self.dup
  new_player.state = offspring_loc.state
  new_player.turn_order = new_player.state.players.maximum(:turn_order) + 1 
  attrs = {}
  self.player_attributes.each {|r| attrs[q.name]=q.value}
  attrs[Terra::PA_HIT_POINTS] = flora? ? 1.0 : (get_game_attr Terra::PA_SIZE)
  new_player.transaction do
    new_player.save
    new_player.introduce_at offspring_loc
    new_player.set_game_attrs attrs
  end
end

def flora?
  return false
end
def on_introduced
  
end

def on_dying
  
end

end
