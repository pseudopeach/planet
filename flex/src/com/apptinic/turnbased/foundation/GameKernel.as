package com.apptinic.turnbased.foundation{
	
import com.apptinic.util.ObjectEvent;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.collections.ArrayCollection;

//[Event(name=PLAYER_ACTED, type="com.apptinic.util.ObjectEvent")] 
//[Event(name=PLAYER_PASSED, type="com.apptinic.util.ObjectEvent")]
[Event(name=GAME_ENDED, type="com.apptinic.util.ObjectEvent")]

public class GameKernel extends EventDispatcher{

//public static const PLAYER_ACTED:String = "PLAYER_ACTED";
//public static const PLAYER_PASSED:String = "PLAYER_PASSED";
public static const GAME_ENDED:String = "GAME_ENDED";

public static const OUTCOME_SINGLE_WINNER:String = "OUTCOME_SINGLE_WINNER";
public static const OUTCOME_DRAW:String = "OUTCOME_DRAW";
	
protected var _turnOrderDelegate:ITurnOrderDelegate;
public function set turnOrderDelegate(input:ITurnOrderDelegate):void {
	_turnOrderDelegate = input;
	_turnOrderDelegate.state = state;
}
public function get turnOrderDelegate():ITurnOrderDelegate{return _turnOrderDelegate;}
public var endGameDelegate:IEndGameDelegate;
	
public var gameStateClass:Class;
protected var state:GameState;

	
public function GameKernel(target:IEventDispatcher=null){
	super(target);
}

//shared singleton
protected static var _shared:GameKernel;
public static function get shared():GameKernel{
	if(!_shared)
		_shared = new GameKernel();
	return _shared
}

public function initGame():void{
	//currentTurnTakerInd = 0;
	state = gameStateClass ? new gameStateClass() : new GameState();
	
	if(!turnOrderDelegate)
		turnOrderDelegate = new DefaultTurnTakerDelegate();
}

public function commitPassAction():void{
	//either prompt the next user or resolve an action
	var actInQuestion:GameAction = state.resolvingAction ? state.resolvingAction : state.topStackItem;
	actInQuestion.listPlayerAsPassed(turnOrderDelegate.currentResponder);
	if(!turnOrderDelegate.isActionSettled(actInQuestion)){
		var responder:Player = turnOrderDelegate.currentResponder;
		responder.prmoptTurn(state.getFiltered(responder));
	}else if(state.topStackItem){
		//there are unresolved actions on the stack
		resolveAction();
	}else{
		//the stack is empty, prompt the next player for their regular turn
		turnOrderDelegate.currentTurnTaker.prmoptTurn(state);
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
	var responder:Player = turnOrderDelegate.currentResponder;
	responder.prmoptTurn(state.getFiltered(responder));
}
protected function resolveAction():void{
	state.resolveAction();
	
	//did someone win?
	if(endGameDelegate.getGameWinner(state))
		endGame();
	
	//prompt next player to respond to this action being un-stacked
	var responder:Player = turnOrderDelegate.currentResponder;
	responder.prmoptTurn(state.getFiltered(responder));
}

protected function endGame():void{
	var e:ObjectEvent = new ObjectEvent(GAME_ENDED);
	var winnerRet:Object = endGameDelegate.getGameWinner(state);
	if(winnerRet as Player)
		e.obj = {outcome:OUTCOME_SINGLE_WINNER, winner:winnerRet};
	else if(winnerRet.hasOwnProperty("length") && winnerRet.length > 1)
		e.obj = {outcome:OUTCOME_DRAW, winners:winnerRet};
	else
		throw new Error("Unknown game outcome");
	dispatchEvent(e);
}


}}