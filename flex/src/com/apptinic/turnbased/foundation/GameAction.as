package com.apptinic.turnbased.foundation{
	
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class GameAction extends EventDispatcher{
	
public static const WAIT_FOR_HUMAN:String = "WAIT_FOR_HUMAN";
	
public var name:String;

public var player:Player;

protected var _passedOnBy:Array = new Array();
//adds user to the list of players that have decided not to respond to this action
public function listPlayerAsPassed(p:Player):uint{
	return _passedOnBy.push(p);
}
public function clearPassList():void{_passedOnBy = new Array();}
public function get passedOnBy():Array{return _passedOnBy;}

protected var _hasResolved:Boolean = false;
public function get hasResolved():Boolean{return _hasResolved;}

public function GameAction(target:IEventDispatcher=null){
	super(target);
}

public function isLegalInCurrentState(state:GameState):Boolean{
	return true;
}

public function resolve(state:GameState):void{
	//action does whatever it does, operating on the game state
	_hasResolved = true;
}

}}