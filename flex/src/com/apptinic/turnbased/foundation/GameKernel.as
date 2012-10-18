package com.apptinic.turnbased.foundation{

import mx.collections.ArrayCollection;

public class GameKernel{
	
protected var _turnOrderDelegate:ITurnOrderDelegate;
public function set turnOrderDelegate(input:ITurnOrderDelegate):void {
	_turnOrderDelegate = input;
	_turnOrderDelegate.state = state;
}
public function get turnOrderDelegate():ITurnOrderDelegate{return _turnOrderDelegate;}
	
public var gameStateClass:Class;
protected var state:GameState;

	
public function GameKernel(){
	super();
}

//shared singleton
protected static var _shared:GameKernel;
public static function get shared():GameKernel{
	if(!_shared)
		_shared = new GameKernel();
	return _shared
}

public function initGame():GameState{
	//currentTurnTakerInd = 0;
	state = gameStateClass ? new gameStateClass(this) : new GameState(this);
	
	if(!turnOrderDelegate)
		turnOrderDelegate = new DefaultTurnTakerDelegate(state);
	state.turnOrderDelegate = turnOrderDelegate;
	
	return state;
}

public function begin():void{
	resumeGame();
}

protected function resumeGame(newAction:GameAction=null):void{
	var action:GameAction;
	
	//main game loop
	while(!state.getGameWinner(state)){
		//use the entered newAction, or prompt for an action
		if(newAction){
			action = newAction;
			newAction = null;
		}else
			action = state.promptNextPlayer();
		
		//process the action
		if(!action){ //player passed
			state.recordPassAction();
			if(state.topStackItem && turnOrderDelegate.isActionSettled(state.activeAction)) 
				state.resolveAction();
			else if(!state.activeAction || state.activeAction && turnOrderDelegate.isActionSettled(state.activeAction))
				state.recordTurnEnd();

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
	state.endGame();
}

}}