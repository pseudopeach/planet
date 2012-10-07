package com.apptinic.turnbased.foundation{
	
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class HumanPlayerShell extends Player{
	
public function HumanPlayerShell(target:IEventDispatcher=null){
	super(target);
}

public function prmoptTurn(state:GameState, context:MoveContext):void{
	//automatically respond to prompt
	var move:GameMove = decideMove(state, context);
	GameKernel.shared.commitMove(move);
}

}}