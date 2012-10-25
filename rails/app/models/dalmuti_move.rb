class DalmutiMove < Game::Action
  attr_accessor :rank, :count, :defeated
  def resolve
    unless defeated
      state.stacked_actions.each { |a| a.defeated = true}
      state.next_turn_leader = player
    end
    
  end
  
  def on_stack
    state.remove_from_hand player, num, rank
  end
  
  def legal_in_current_state?(state)
    return state.hand_count_of_rank(player, rank) >= count
  end
end