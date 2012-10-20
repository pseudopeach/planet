class TestPlayer < Player

def initialize
  super
  @@log = []
end

def log_has(item)
  return @@log.index item
end
  
def prompt(state)
  case @name
  when "Justin"
    if(state.status == Game::TURN_END && !log_has("move1"))
      mv = GameAction.new
      mv.name = "move1";
      @@log.push("move1");
      return mv;
    end
    if(state.status == Game::ACTION_STACKED && log_has("resp1") && !log_has("resp2"))
      mv = GameAction.new
      mv.name = "resp2";
      @@log.push("resp2");
      return mv;
    end

  when "Kyle"
    if(state.status == Game::ACTION_STACKED && log_has("move1") && !log_has("resp1"))
      mv = GameAction.new
      mv.name = "resp1";
      @@log.push("resp1");
      return mv;
    end
    if(state.status == Game::TURN_END && log_has("move1") && !log_has("move2"))
      mv = GameAction.new
      mv.name = "move2";
      @@log.push("move2");
      return mv;
    end
   
  when "Sarah"
    if(state.status == Game::ACTION_RESOLVED && !log_has("resolved1"))
      mv = GameAction.new
      mv.name = "resolved1";
      @@log.push("resolved1");
      return mv;
    end
   
end
return nil
end


end