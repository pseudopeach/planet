package com.apptinic.turnbased.foundation{
	
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.collections.ArrayCollection;

public class GameKernel extends EventDispatcher{
	
	
protected var players:ArrayCollection = new ArrayCollection();
protected var state:GameState;
protected var actionStack:Array = new Array();
	
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

public function init():void{
	currentTurnTakerInd = 0;
	state = new GameState();
}


protected var currentTurnTakerInd:int = 0;
public var currentTurnTaker:Player;
protected function advanceTaker():void{
	currentTurnTakerInd = (currentTurnTakerInd+1) % players.length;
	currentTurnTaker = players[currentTurnTakerInd];
}

protected function nextResponderIndex():int{
	return 0;
}

public function commitMove(move:GameMove):void{
	//movesStack.push(move);
	//currentResponderInd = currentTurnTakerInd;
	//advanceResponder();
	//if(moveStack[movesStack.length-1].player == currentResponder)
		//resolveStack();
	//reactToMove(move);
	//advanceTurnPlayer();
	//currentTurnPlayer.prmoptTurn(state.filterForPlayer(player), null /* *** */);
}
public function followup(action:GameMove):void{
	actionStack.push(action);
	trace("follow up for: "+action.name+", levels deep: "+actionStack.length);
	// **** set up current responder iterator
	var consecPasses:int = 0;
	
	while(consecPasses < players.length){
		var responder:Player = players[nextResponderIndex()];
		var act:GameMove = responder.prmoptTurn(state,null);
		if(act){
			trace("returned: "+act.name);
			followup(act);
			consecPasses = 0;
		}else{
			consecPasses++;
			trace(responder.name + " passes");
		}
	}
	actionStack.pop();
	trace(action.name + " resolves");
}

protected function reactToMove(move:GameMove):void{
	
}


}}