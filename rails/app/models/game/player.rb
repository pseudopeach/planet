class Game::Player < ActiveRecord::Base
  
include Game::ExtendedAttributes
include Game::ItemAccounting
  
belongs_to :game, :class_name=>"Game::State", :foreign_key=>"state_id", :inverse_of=>:players

belongs_to :user
belongs_to :location

belongs_to :prototype, :class_name=>"Game::Player", :foreign_key=>"prototype_player_id"
belongs_to :owner_player, :class_name=>"Game::Player", :foreign_key=>"owner_player_id"
has_many :owned_creatures, :class_name=>"Game::Player", :foreign_key=>"owner_player_id"

belongs_to :next_player, :class_name=>"Game::Player", :inverse_of=>:prev_player
has_one :prev_player, :class_name=>"Game::Player", :foreign_key=>"next_player_id", :inverse_of=>:next_player

has_many :observations, :class_name=>"Terra::PlayerObserver", :foreign_key=>"observer_id", :dependent=>:destroy
has_many :observed_players, :class_name=>"Game::Player", :through=>:observations
has_many :observers, :class_name=>"Terra::PlayerObserver", :foreign_key=>"player_id"
has_many :observing_players, :class_name=>"Game::Player", :through=>:observers
has_many :player_attributes, :dependent=>:destroy
has_many :actions, :class_name=>"Game::Action"
has_many :items

@@loaded_prototypes = {}

def make_prototype
  return {:success=>false, :error=>"Not enough DNA Points"} unless self.user.item_count(Terra::DNA_PTS) >= engineering_cost
  if self.prototype || self.game
    return {:success=>false, :error=>"Not elligable for prototyping"}
  end
  self.transaction do
    self.prototype = self
    self.save
    self.user.item_count_add Terra::DNA_PTS, -engineering_cost
  end
  return {:success=>true}
end

def create_launch_action(owner_player,location=nil)
  action = Terra::ActLaunch.new(:player=>owner_player, :target_player=>self)
  if location
    action.location = location
  else
    action.location = owner_player.game.locations.first
  end
  return action
end


attr_accessor :xdata
before_save :serialize_data
#after_initialize :load_broadcastables 
after_initialize :deserialize_data

def prototype
  return nil unless prototype_player_id
  return @prototype if @prototype
  unless @prototype = @@loaded_prototypes[prototype_player_id]
    @prototype = super
    @prototype.preload_all_game_attrs
    @@loaded_prototypes[prototype_player_id] = @prototype
  end
  return @prototype
end
def prototype=(input)
  super(input)
  @prototype = input
  @@loaded_prototypes[prototype_player_id] = @prototype
end 

def game_attr(name, unwrap=true)
  @loaded_game_attributes = {} unless @loaded_game_attributes
  if @loaded_game_attributes.key? name
    out = @loaded_game_attributes[name]
  elsif prototype && (prf = self.prototype.preloaded_game_attrs[name])
    #puts "found attr on prototype"
    out = prf
  else
    #puts "prototype nil?:#{self.prototype.nil?}  pattrs:#{self.prototype.preloaded_game_attrs.inspect}"
    out = player_attributes.where(:name=>name).first
  end
  @loaded_game_attributes[name] = out #will store nils
  
  unless out
    cname = ("DEF_"+name.to_s).upcase
    if Terra.const_defined? cname
      return Terra.const_get cname
    end
  end
  
  return (unwrap && out) ? out.value : out
end

def game_attrs=(hash_in)
  preload_game_attrs hash_in.keys
  self.transaction do
    hash_in.each do |key, item|
      if @loaded_game_attributes.key?(key)
        #item already loaded
        attr = @loaded_game_attributes[key]
        attr.value = item
        @loaded_game_attributes[key].save
      else
        #item needs to be created
        attr = Game::PlayerAttribute.new(:name=>key, :value=>item)
        player_attributes << attr
        @loaded_game_attributes[name] = attr
      end
      attr.history_entries << Game::PlayerAttrEntry.new(:action=>game.resolving_action, :value=>attr.value)
    end #each loop
  end #transaction
end

def game_attr_add(name, d_value)
  @loaded_game_attributes = {} unless @loaded_game_attributes
  if @loaded_game_attributes.key?(name)
    #item already loaded
    attr = @loaded_game_attributes[name]
    attr.value += d_value
    attr.save
  elsif attr = player_attributes.where(:name=>name).first
    #item exists, but not already loaded
    @loaded_game_attributes[name] = attr
    attr.value += d_value
    attr.save
  else
    #item needs to be created
    attr = Game::PlayerAttribute.new(:name=>name, :value=>d_value)
    player_attributes << attr
    @loaded_game_attributes[name] = attr
  end
  attr.history_entries << Game::PlayerAttrEntry.new(:action=>game.resolving_action, :value=>attr.value)
end

def preload_game_attrs(array_in=nil)
  @loaded_game_attributes = {} unless @loaded_game_attributes
  load_keys = array_in - @loaded_game_attributes.keys
  load_keys -= self.prototype.preloaded_game_attrs.keys if self.prototype
  if load_keys.length > 0
    existing_attrs = player_attributes.where(:name=>load_keys)
    existing_attrs.each{|a| @loaded_game_attributes[a.name.to_sym] = a }
  end
end

def preload_all_game_attrs
  @loaded_game_attributes = {}
  self.player_attributes.all.each do |q|
    @loaded_game_attributes[q.name.to_sym] = q
  end
end

def preloaded_game_attrs
  if @loaded_game_attributes
    return @loaded_game_attributes
  else
    return {}
  end
end

def creature_player?
  return !self.owner_player.nil?
end

def flora?
  return false
end
def parasite?
  return false
end
def enemy?(other_player)
  return (self.user_id!=other_player.user_id)
end

def on_born
  
end

def on_dying
  
end

def prompt(state)
  return nil
end

#override methods to take advantage of the fact that all players have been loaded already in the game object

def next_player
  if @next_player
  elsif game && (@next_player = game.players.find{|p| self.next_player_id == p.id})
  else
    @next_player = super
  end
  return @next_player
end
def prev_player
  if @prev_player
  elsif game && (@prev_player = game.players.find{|p| self.id == p.next_player_id})
  else
    @prev_player = super
  end
  return @prev_player
end

def next_player=(input)
  @next_player = input
  super input
end
def prev_player=(input)
  @prev_player = input
  super input
end

end
