package com.apptinic.turnbased.foundation{
	
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class GameAction extends EventDispatcher{
	
public static const WAIT_FOR_HUMAN:String = "WAIT_FOR_HUMAN";
	
public var name:String;

public var player:Player;
public var nPassResponses:int = 0;
	
public function GameAction(target:IEventDispatcher=null){
	super(target);
}

public function resolve(state:GameState):void{
	//action does whatever it does, operating on the game state
}

}}