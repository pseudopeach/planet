class Tester
def go
  @gamek = GameKernel.new
  @state = @gamek.init_game
  @state.end_game_delegate = self
  
  k = TestPlayer.new
  k.name = "Kyle"
  j =  TestPlayer.new
  j.name = "Justin"
  s =  TestPlayer.new
  s.name = "Sarah"
  @state.players = [s,k,j]
  
  @state.add_observer(self,Game::TURN_END,:on_game_event);
  @state.add_observer(self,Game::PROMPTING_PLAYER,:on_game_event);
  @state.add_observer(self,Game::PLAYER_PASSED,:on_game_event);
  @state.add_observer(self,Game::ACTION_STACKED,:on_game_event);
  @state.add_observer(self,Game::ACTION_RESOLVED,:on_game_event);
  @state.add_observer(self,Game::GAME_OVER,:on_game_event);
  
  @turn = 0
  @gamek.begin
end

def on_game_event event
  if(event[:message] == Game::TURN_END)
    @turn += 1
  end
  str = event[:message].to_s
  str += " #{event[:obj].name}" if event[:obj].respond_to? :name
  puts str 
  
end

def game_winner st
  if(@turn>12)
    return @state.players[0]
  else
    return nil;
  end
end



end