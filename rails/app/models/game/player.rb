class Game::Player < ActiveRecord::Base
belongs_to :game, :class_name=>"Game::State"

belongs_to :user
belongs_to :location

belongs_to :prototype, :class_name=>"Game::Player", :foreign_key=>"prototype_player_id"
belongs_to :parent_player, :class_name=>"Game::Player", :foreign_key=>"parent_player_id"
has_many :child_creatures, :class_name=>"Game::Player", :foreign_key=>"parent_player_id"

belongs_to :next_player, :class_name=>"Game::Player"
has_one :prev_player, :class_name=>"Game::Player", :foreign_key=>"next_player_id"

has_many :player_observers, :dependent=>:destroy
has_many :player_attributes, :dependent=>:destroy
has_many :actions, :class_name=>"Game::Action"
has_many :items

include Game::ItemAccounting


def prototype
  return {:success=>false} unless self.user.item_count(Terra::DNA_PTS) >= engineering_cost
  self.transaction do
    self.prototype = self
    self.save
    self.user.item_count_add Terra::DNA_PTS, -engineering_cost
  end
  return {:success=>true}
end


attr_accessor :xdata
before_save :serialize_data
#after_initialize :load_broadcastables 
after_initialize :deserialize_data 

def game_attr(name, unwrap=true)
  @loaded_game_attributes = {} unless @loaded_game_attributes
  if @loaded_game_attributes.key? name
    return @loaded_game_attributes[name]
  end
  out = player_attributes.where(:name=>name).first
  @loaded_game_attributes[name] = out #will store nils
  
  return (unwrap && out) ? out.value : out
end

def tem_get_attr
  return @loaded_game_attributes
end

def game_attrs=(hash_in)
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

def creature_player?
  return true
end

def flora?
  return false
end
def parasite?
  return false
end

def on_dying
  
end

def prompt(state)
  return nil
end

def serialize_data
  self.data = @xdata.empty? ? nil : @xdata.to_json
end
def deserialize_data
  @xdata = self.data ? JSON(self.data) : {}
end
  

end
