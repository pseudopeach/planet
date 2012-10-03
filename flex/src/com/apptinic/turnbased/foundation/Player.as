package com.apptinic.turnbased.foundation{
	
import com.apptinic.util.ObjectEvent;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

//[(event=PLAYER_MOVE_PROMPT, type=

public class Player extends EventDispatcher{
	
public static const PLAYER_MOVE_PROMPT:String = "PLAYER_MOVE_PROMPT";

	
public function Player(target:IEventDispatcher=null){
	super(target);
}

public function prmoptMove(state:GameState, context:MoveContext):void{
	var ev:ObjectEvent = new ObjectEvent(PLAYER_MOVE_PROMPT);
	ev.obj = {state:state, context:context};
	dispatchEvent(ev);
}

public function commitMove(move:GameMove):void{
	kernel.commitMove(move);
}

}}