package com.apptinic.turnbased.foundation{
	
import com.apptinic.util.ObjectEvent;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

[Event(name=PROMPTING_PLAYER, type="com.apptinic.util.ObjectEvent")]
[Event(name=PLAYER_PASSED, type="com.apptinic.util.ObjectEvent")]
[Event(name=TURN_END, type="com.apptinic.util.ObjectEvent")]
[Event(name=ACTION_STACKED, type="com.apptinic.util.ObjectEvent")]
[Event(name=ACTION_RESOLVED, type="com.apptinic.util.ObjectEvent")]
[Event(name=GAME_OVER, type="com.apptinic.util.ObjectEvent")]

public class GameState extends EventDispatcher{
	
public static const PROMPTING_PLAYER:String = "PROMPTING_PLAYER";
public static const PLAYER_PASSED:String = "PLAYER_PASSED";
public static const TURN_END:String = "TURN_END";
public static const ACTION_STACKED:String = "ACTION_STACKED";
public static const ACTION_RESOLVED:String = "ACTION_RESOLVED";
public static const GAME_OVER:String = "GAME_OVER";

public static const OUTCOME_SINGLE_WINNER:String = "OUTCOME_SINGLE_WINNER";
public static const OUTCOME_DRAW:String = "OUTCOME_DRAW";
	
public var actionStack:Array = new Array();
public var resolvingAction:GameAction;
public var turnOrderDelegate:ITurnOrderDelegate;
public var endGameDelegate:IEndGameDelegate;

public var ended:Boolean = false;

protected var _players:Array = new Array();
public function get players():Array{return _players;}
public function set players(input:Array):void{
	_players = input;
	turnOrderDelegate.setupPlayerOrder();
}
protected var _status:String;
public function get status():String{return _status;}

// **** whose turn accessor?

public function GameState(target:IEventDispatcher=null){
	super(target);
}

public function stackAction(action:GameAction):void{
	resolvingAction = null;
	action.clearPassList();
	actionStack.push(action);

	_status = ACTION_STACKED;
	var e:ObjectEvent = new ObjectEvent(ACTION_STACKED);
	e.obj = action;
	dispatchEvent(e);
}
public function get topStackItem():GameAction{
	if(actionStack.length > 0)
		return actionStack[actionStack.length-1];
	else
		return null;
}
public function get activeAction():GameAction{
	return resolvingAction ? resolvingAction : topStackItem;
}

public function resolveAction():GameAction{
	resolvingAction = actionStack.pop();
	resolvingAction.resolve(this);
	resolvingAction.clearPassList();
	
	_status = ACTION_RESOLVED;
	var e:ObjectEvent = new ObjectEvent(ACTION_RESOLVED);
	e.obj = resolvingAction;
	dispatchEvent(e);
	
	return resolvingAction;
}

public function promptNextPlayer():GameAction{
	var e:ObjectEvent;
	var player:Player = activeAction ? turnOrderDelegate.currentResponder : turnOrderDelegate.currentTurnTaker;
	
	if(canPlayerRespond(player)){
		e = new ObjectEvent(PROMPTING_PLAYER);
		e.obj = player;
		dispatchEvent(e);
		
		return player.prompt(this.getFiltered(player));
	}else
		return null;
}

public function recordPassAction():void{
	var player:Player;
	if(activeAction){
		player = turnOrderDelegate.currentResponder;
		activeAction.listPlayerAsPassed(player);
	}else
		player = turnOrderDelegate.currentTurnTaker;
		
	var e:ObjectEvent = new ObjectEvent(PLAYER_PASSED);
	e.obj = player;
	dispatchEvent(e);
}

public function recordTurnEnd():void{
	turnOrderDelegate.stackWasResolved();
	resolvingAction = null;
	
	_status = TURN_END;
	var e:ObjectEvent = new ObjectEvent(TURN_END);
	dispatchEvent(e);
}

protected function canPlayerRespond(player:Player):Boolean{
	return true;
}

public function getFiltered(player:Player):GameState{
	return this;
}

public function get currentContext():GameContext{
	return null;
}

public function getGameWinner(state:GameState):Player{
	if(endGameDelegate)
		return endGameDelegate.getGameWinner(this);
	return null;
}

public function endGame():void{
	ended = true;
	var e:ObjectEvent = new ObjectEvent(GAME_OVER);
	var winnerRet:Object = endGameDelegate.getGameWinner(this);
	if(winnerRet as Player)
		e.obj = {outcome:OUTCOME_SINGLE_WINNER, winner:winnerRet};
	else if(winnerRet.hasOwnProperty("length") && winnerRet.length > 1)
		e.obj = {outcome:OUTCOME_DRAW, winners:winnerRet};
	else
		throw new Error("Unknown game outcome");
	dispatchEvent(e);
}

}}