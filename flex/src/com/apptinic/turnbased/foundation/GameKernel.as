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
		turnOrderDelegate = new DefaultTurnTakerDelegate();
	
	return state;
}

public function begin():void{
	state.promptPlayer(turnOrderDelegate.currentTurnTaker,true);
}

public function commitPassAction():void{
	//either prompt the next user or resolve an action
	state.recordPassAction(turnOrderDelegate.currentResponder);
	if(!turnOrderDelegate.isActionSettled(state.activeAction)){
		state.promptPlayer(turnOrderDelegate.currentResponder);
	}else if(state.topStackItem){
		//there are unresolved actions on the stack
		resolveAction();
	}else{
		//the stack is empty, prompt the next player for their regular turn
		state.promptPlayer(turnOrderDelegate.currentTurnTaker,true);
	}
}
public function commitAction(action:GameAction):void{
	//validation
	action.player = state.topStackItem ? 
		turnOrderDelegate.currentResponder : 
		turnOrderDelegate.currentTurnTaker;
	if(!action.isLegalInCurrentState(state)) return;
	
	//stack the action
	state.stackAction(action);
	
	//prompt next player to respond to this action being stacked
	state.promptPlayer(turnOrderDelegate.currentResponder);
}
protected function resolveAction():void{
	state.resolveAction();
	
	//did someone win?
	if(state.getGameWinner(state))
		state.endGame();
	
	//prompt next player to respond to this action being un-stacked
	state.promptPlayer(turnOrderDelegate.currentResponder);
}

}}