class Terra::ActMove < Game::Action
  
  def resolve(state)
    super state
    player.location = @xdata[:new_loc]
    player.save
   
    
    #notify followers of player
    in_range = []
    r_observable = self.player.game_attr Terra::PA_OBSERVABLE_RANGE
    r_observable = Terra::DEF_OBSERVABLE_RANGE unless r_observable
    player.location.nearby_locations(r_observable).each do |loc|
      loc.players.each do |pl|
        if pl.respond_to? :on_enemy_move && pl.user_id != player.user_id
          r_observe = self.player.game_attr Terra::PA_OBSERVABLE_RANGE
          r_observe = Terra::DEF_OBSERVABLE_RANGE unless r_observe
          if r_observe >= player.location.range_to(pl.location)
            pl.on_enemy_move self #trigger the enemy move handler of all enemies that have one and are close enough to observe
            in_range << pl
          end
        end
      end
    end
    
    #unregister observers that are no longer in range
    unreg = player.player_observers - in_range
    unreg.each do |q|
      state.remove_player_observer q, action.player
    end
  end
  
  
end
