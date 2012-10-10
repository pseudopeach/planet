package com.apptinic.turnbased.foundation{
	
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class GameState extends EventDispatcher{
	
public var actionStack:Array = new Array();
public var resolvingAction:GameAction;
public var players:Array = new Array();
public var kernel:GameKernel;
//protected var stackScopes:Array = new Array();
	
public function GameState(kernel:GameKernel, target:IEventDispatcher=null){
	super(target);
	this.kernel = kernel;
}

public function stackAction(action:GameAction):void{
	resolvingAction = null;
	action.clearPassList();
	actionStack.push(action);
}
public function get topStackItem():GameAction{
	if(actionStack.length > 0)
		return actionStack[actionStack.length-1];
	else
		return null;
}

public function resolveAction():GameAction{
	resolvingAction = actionStack.pop();
	resolvingAction.resolve(this);
	resolvingAction.clearPassList();
	return resolvingAction;
}

public function promptPlayer(player:Player):void{
	if(canPlayerRespond())
		player.prompt(this.getFiltered(player));
	else
		kernel.commitPassAction();
}

protected function canPlayerRespond():Boolean{
	return true;
}

public function getFiltered(player:Player):GameState{
	return this;
}

}}