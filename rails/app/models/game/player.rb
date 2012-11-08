class Game::Player < ActiveRecord::Base

belongs_to :game, :class_name=>"Game::State"
has_many :actions, :class_name=>"Game::Action"
has_many :items
belongs_to :user
has_many :player_observers
has_many :player_attributes
#has_many :upgrades

def introduce(loc_i,loc_j)
  #introduces ai player to game
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
        new_attr = (player_attributes << Game::PlayerAttribute.new(:name=>key, :value=>item))
        @loaded_game_attributes[key] = new_attr
      end
    end #each loop
  end #transaction
      
end

def game_attr_add(name, d_value)
  if @loaded_game_attributes.key?(key)
    #item already loaded
    @loaded_game_attributes[key].value += d_valule
    @loaded_game_attributes[key].save
  elsif found = player_attributes.where(:name=>key).first
    #item exists, but not already loaded
    @loaded_game_attributes[key] = found
    found.value += d_value
    found.save
  else
    #item needs to be created
    new_attr = (player_attributes << Game::PlayerAttribute.new(:name=>key, :value=>item))
    @loaded_game_attributes[key] = new_attr
  end
end

end
