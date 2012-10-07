package com.apptinic.turnbased.foundation{
	
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.collections.ArrayCollection;

public class GameKernel extends EventDispatcher{
	
public var turnOrderDelegate:ITurnOrderDelegate;
	
protected var players:ArrayCollection = new ArrayCollection();
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
	state = new GameState();
	
	if(!turnOrderDelegate)
		turnOrderDelegate = new DefaultTurnTakerDelegate();
}



public function commitPassAction():void{
	//either prompt the next user or resolve an action
	var actInQuestion:GameAction = state.resolvingAction ? state.resolvingAction : state.topStackItem;
	actInQuestion.nPassResponses++;
	if(actInQuestion.nPassResponses == players.length)
		resolveAction();
	else
		turnOrderDelegate.getNextResponder(state).prmoptTurn(state,null);
}
public function commitAction(action:GameAction, wasResolved:Boolean=false):void{
	//stack the action
	state.stackAction(action);
	
	//prompt next player to respond to this action being stacked
	turnOrderDelegate.getNextResponder(state).prmoptTurn(state,null);
}
protected function resolveAction():void{
	state.resolveAction();
	
	//prompt next player to respond to this action being un-stacked
	turnOrderDelegate.getNextResponder(state).prmoptTurn(state,null);
}


}}