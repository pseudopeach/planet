package com.apptinic.terraschema{
	import com.apptinic.util.ASRecord;
	import com.apptinic.util.ASRecordClass;
	import com.apptinic.util.RequestQueue;
	import com.apptinic.util.RequestQueueEvent;
	import com.apptinic.util.UberCollection;
	
[Bindable]
public class GameData extends ASRecord{
	
public static const TURN_COMPLETION:String = "Game::TurnCompletion";
	
// the source data
public var turns:UberCollection;
public var unfinishedTurn:TurnCompletion;
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

public function GameData(stateId:int){
	super();
	enterInSchema(GameData, [
		{type:HAS_MANY, propName:"originalPlayers", assocClass:Player},
		{type:HAS_MANY, propName:"originalLocations", assocClass:Location},
		{type:HAS_MANY, assocClass:Player},
		{type:HAS_MANY, assocClass:Location},
		//{type:HAS_MANY, assocClass:Action},
		{type:HAS_MANY, propName:"turns", assocClass:TurnCompletion, fKeyName:"turnCompletionId"},
	]);
	this.id = stateId;
	//originalPlayers = new UberCollection();
	//originalLocations = new UberCollection();
	remote.addEventListener(RequestQueueEvent.RESULT, onData);
}

public function resetGameState():void{
	players.removeAll();
	locations.removeAll();
	var i:int;
	//if(!players) players = new UberCollection();
	for each(var player:Player in originalPlayers) {
		player.attributes.removeAll();
		players.addItem(player);
	}
	//if(!locations) locations = new UberCollection();
	for each(var loc:Location in originalLocations) {
		loc.players.removeAll();
		locations.addItem(loc);
	}
	_gamePosition = 0;
}
	
public function gotoAction(input:uint):void{
	
}
public function stepOnce():void{
	
}

public function get isAtEnd():Boolean{
	return false;
	//return _gamePosition == actions.length && stackedActions.length == 0;
}

protected var remote:RequestQueue = new RequestQueue();

public function getData(afterTurnId:int=-1):void{
	var params:Object = {id:this.id};
	if(afterTurnId != -1) params.afterTurn = afterTurnId;
	remote.addRequest("history","Play",params);
}
protected function onData(event:RequestQueueEvent):void{
	var item:Object;
	if(event.data.hasOwnProperty("originalPlayers"))
		this.update({originalPlayers:event.data.originalPlayers});
	if(event.data.hasOwnProperty("originalLocations"))
		this.update({originalLocations:event.data.originalLocations});
	var rawHistory:Array = event.data.events;
	if(!turns) turns = new UberCollection();
	var actionsThisTurn:Array = [];
	for each(item in rawHistory){
		if(item.eType == TURN_COMPLETION){
			var turn:TurnCompletion = ASRecord.findOrCreate(TurnCompletion,item.id) as TurnCompletion;
			item.actions = actionsThisTurn;
			turn.update(item);
			turns.addItem(turn);
			actionsThisTurn = [];
		}else{
			actionsThisTurn.push(item);
		}
	}
	unfinishedTurn = new TurnCompletion();
	unfinishedTurn.update({actions:actionsThisTurn});
	trace("got game data:" +rawHistory.length);
}


}}