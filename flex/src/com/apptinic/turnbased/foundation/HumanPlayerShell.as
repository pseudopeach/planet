package com.apptinic.turnbased.foundation{
	
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class HumanPlayerShell extends EventDispatcher{
	
public function HumanPlayerShell(target:IEventDispatcher=null){
	super(target);
}

public function prmoptMove(state:GameState, context:MoveContext):GameMove{
	//given the state visible to this player entity and this move context, return a move
	
	//**** stub
	return null;
}

}}