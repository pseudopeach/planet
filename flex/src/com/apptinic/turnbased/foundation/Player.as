package com.apptinic.turnbased.foundation{
	
import com.apptinic.util.ObjectEvent;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

[Event(name=PLAYER_MOVE_PROMPT, type="com.apptinic.util.ObjectEvent")] 

public class Player extends EventDispatcher{
	
public static const PLAYER_MOVE_PROMPT:String = "PLAYER_MOVE_PROMPT";
public var name:String;
	
public function Player(target:IEventDispatcher=null){
	super(target);
}

public function prompt(state:GameState):GameAction{
	var e:ObjectEvent = new ObjectEvent(PLAYER_MOVE_PROMPT);
	e.obj = {state:state};
	dispatchEvent(e);
	return new GameAction(true);
}



}}