package com.apptinic.turnbased.foundation{
	import flash.utils.Dictionary;

public class DefaultTurnTakerDelegate implements ITurnOrderDelegate{
	
protected var turnTakerInd:int;
protected var _state:GameState;
public function set state(input:GameState):void{_state=input;}
protected var playerAfter:Dictionary = new Dictionary();
public var playerCanRespondToSelf:Boolean = false;
public var playerRespondsToSelfAfterOtherPlayers:Boolean = false;

public function DefaultTurnTakerDelegate(state:GameState){
	this.state = state;
}

public function setupPlayerOrder(initialTurnTaker:int = 0):void{
	turnTakerInd = initialTurnTaker;
	for(var i:int=1;i<_state.players.length;i++)
		playerAfter[_state.players[i-1]] = _state.players[i];
	playerAfter[_state.players[_state.players.length-1]] = _state.players[0];
}
	
public function stackWasResolved():void{
	turnTakerInd++;
	turnTakerInd %= _state.players.length;
}
public function get currentTurnTaker():Player{
	return _state.players[turnTakerInd];
}


public function get currentResponder():Player{
	var activeAction:GameAction = _state.activeAction;
	if(activeAction.passedOnBy.length == 0){
		if(playerCanRespondToSelf && !playerRespondsToSelfAfterOtherPlayers)
			return _state.activeAction.player;
		else
			return playerAfter[activeAction.player];
	}
	return playerAfter[activeAction.passedOnBy[activeAction.passedOnBy.length-1]];
}


public function isActionSettled(action:GameAction):Boolean{
	if(playerCanRespondToSelf)
		return action.passedOnBy.length == _state.players.length;
	else
		return action.passedOnBy.length == _state.players.length-1;
}
	


}}