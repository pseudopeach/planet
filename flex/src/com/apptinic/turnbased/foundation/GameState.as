package com.apptinic.turnbased.foundation{
	
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class GameState extends EventDispatcher{
	
public var actionStack:Array = new Array();
public var resolvingAction:GameAction;
public var players:Array = new Array();
//protected var stackScopes:Array = new Array();
	
public function GameState(target:IEventDispatcher=null){
	super(target);
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

public function getFiltered(player:Player):GameState{
	return null;
}

}}