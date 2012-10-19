class GameKernel

attr_accessor :game_state_class

def turn_order_delegate= input
  @turn_order_delegate = input
  @turn_order_delegate.state = @state
end
def turn_order_delegate
  return @turn_order_delegate
end
  
#shared singleton
def self.shared
  if(!@@shared)
    @@shared = GameKernel.new
  return @@shared
end



def initGame
  #currentTurnTakerInd = 0;
  @state = @game_state_class ? @game_state_class.new(self) : GameState.new(self)
  
  if(!@turn_order_delegate)
    @turn_order_delegate = DefaultTurnTakerDelegate.new(@state);
  state.turnOrderDelegate = turnOrderDelegate;
  
  return @state
end


def begin{
  resumeGame;
}
=begin
  

protected function resumeGame(newAction=null):void{
  var action;
  
  //main game loop
  while(!state.getGameWinner(state)){
    //use the entered newAction, or prompt for an action
    if(newAction){
      action = newAction;
      newAction = null;
    }else
      action = state.promptNextPlayer;
    
    //process the action
    if(!action){ //player passed
      state.recordPassAction;
      if(state.topStackItem && turnOrderDelegate.isActionSettled(state.activeAction)) 
        state.resolveAction;
      else if(!state.activeAction || state.activeAction && turnOrderDelegate.isActionSettled(state.activeAction))
        state.recordTurnEnd;

    }else if(action.isWaitRequest)
      return; //exit the game loop until we resume with the human player's move
    else{
      //it's a real action, validate it
      action.player = state.activeAction ? turnOrderDelegate.currentResponder : turnOrderDelegate.currentTurnTaker;
      if(!action.isLegalInCurrentState(state)) 
        return; //ignores this illegal move
      
      //stack the action
      state.stackAction(action);
    }
  }
  state.endGame;
}

}}
=end

# (\w):\w+ -> \1
# () -> ""
# public function -> def
# // -> #



end