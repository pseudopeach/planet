class Game::PlayerAttrEntry < ActiveRecord::Base
  belongs_to :action
  belongs_to :player_attribute, :inverse_of=>:history_entries
  belongs_to :turn_completion
  
  def self.record_entry(attribute, new_value)
    game = attribute.player.game
    entry = Game::PlayerAttrEntry.new(:action=>game.active_action, :value=>new_value)
    entry.turn_completion = game.last_completed_turn unless game.active_action
    attribute.history_entries << entry
  end
end