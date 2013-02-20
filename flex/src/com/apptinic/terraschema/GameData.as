package com.apptinic.terraschema{
	import com.apptinic.util.ASRecord;
	import com.apptinic.util.UberCollection;
	
[Bindable]
public dynamic class GameData extends ASRecord{
	
// the source data
public var actions:UberCollection;
public var originalPlayers:UberCollection;
public var originalLocations:UberCollection;

// snapshot lists
[bindable] public var players:UberCollection;
[bindable] public var locations:UberCollection;
[bindable] public var stackedActions:UberCollection = new UberCollection();

protected var _gamePosition:uint=0;
public function get gamePosition():uint {return _gamePosition;}
public function set gamePosition(input:uint):void{
	gotoAction(input);
}

public function GameData(){
	super();
	enterInSchema(GameData, [
		{type:HAS_MANY, assocClass:Player},
		{type:HAS_MANY, assocClass:Location},
		{type:HAS_MANY, assocClass:Action},
	]);
}

public function resetGameState():void{
	players.removeAll();
	var i:int;
	for(i=0;i<originalPlayers.length;i++) {
		var player:Player = originalPlayers[i];
		player.attributes.removeAll();
		players.addItem(player);
	}
	for(i=0;i<originalLocations.length;i++) {
		var loc:Location = originalLocations[i];
		loc.players.removeAll();
		locations.addItem(loc);
	}
	_gamePosition = 0;
}
	
public function gotoAction(input:uint):void{
	if(input < _gamePosition)
		resetGameState();
	
	while(!isAtEnd && _gamePosition < input)
		stepOnce();
}
public function stepOnce():void{
	var next:Action = nextAction;
	var top:Action = topAction;
	if(topAction && (!nextAction || topAction.resolvedAt.time < nextAction.createdAt.time))
		resolveAction();
	else{
		stackedActions.addItem(next);
		_gamePosition++;
	}
}
protected function resolveAction():void{
	var topInd:int = stackedActions.length-1;
	var ract:Action = stackedActions[topInd];
	ract.execute(this);
	stackedActions.removeItemAt(topInd);
}
public function get isAtEnd():Boolean{
	return _gamePosition == actions.length && stackedActions.length == 0;
}
public function get topAction():Action{
	return stackedActions.length > 0 ? stackedActions[stackedActions.length-1] : null;
}
public function get nextAction():Action{
	return actions.length > 0 ? actions[actions.length-1] : null;
}


}}