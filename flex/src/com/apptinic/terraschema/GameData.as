package com.apptinic.terraschema{
	import com.apptinic.terraview.ContinentBuilder;
	import com.apptinic.util.ASRecord;
	import com.apptinic.util.RequestQueue;
	import com.apptinic.util.RequestQueueEvent;
	import com.apptinic.util.SphereShape;
	import com.apptinic.util.UberCollection;
	
	import mx.collections.ArrayCollection;
	
	
[Bindable]
public class GameData extends ASRecord{
	
public static const TURN_COMPLETION:String = "Game::TurnCompletion";
public static const EVENT_LOCATION_ADDED:String = "locationAdded";
public static const EVENT_PLAYER_ADDED:String = "playerAdded";
public static const EVENT_HISTORY_ADDED:String = "historyAdded";
public static const EVENT_LOCATIONS_RESET:String = "locationsReset";
public static const EVENT_PLAYER_REMOVED:String = "playerRemoved";
public static const EVENT_HISTORY_REMOVED:String = "historyRemoved";
	
// the source data
public var turns:UberCollection;
public var unfinishedTurn:GameTurn;
public var originalPlayers:UberCollection;
public var originalLocations:UberCollection;

// snapshot lists
[bindable] public var players:UberCollection;
[bindable] public var locations:UberCollection;
[bindable] public var stackedActions:UberCollection = new UberCollection();

protected var _completedTurnIdx:uint=0;
public function get gamePosition():uint {return _completedTurnIdx;}
protected var turnActionsByResolution:ArrayCollection;


public function GameData(stateId:int=NaN){
	super();
	enterInSchema(GameData, [
		{type:HAS_MANY, propName:"originalPlayers", assocClass:Player},
		{type:HAS_MANY, propName:"originalLocations", assocClass:Location},
		{type:HAS_MANY, assocClass:Player},
		{type:HAS_MANY, assocClass:Location},
		//{type:HAS_MANY, assocClass:Action},
		{type:HAS_MANY, propName:"turns", assocClass:GameTurn, fKeyName:"turnCompletionId"},
	]);
	if(!isNaN(stateId)) 
		this.id = stateId;
	//originalPlayers = new UberCollection();
	//originalLocations = new UberCollection();
	remote.addEventListener(RequestQueueEvent.RESULT, onData);
	/*
	turnActionsByResolution = new ArrayCollection();
	var resSort:Sort = new Sort();
	resSort.fields[new SortField("resolvedAt")];
	turnActionsByResolution.sort = resSort;*/
}

public function resetGameState():void{
	players.removeAll();
	locations.removeAll();
	
	players = originalPlayers;
	locations = originalLocations;
	_completedTurnIdx = 0;
}
	
public function gotoTurn(input:uint):void{
	if(input < _completedTurnIdx)
		resetGameState();
		
	while(_completedTurnIdx < input) gotoNextTurn();
}
public function gotoNextTurn():void{
	var turn:GameTurn = turns[_completedTurnIdx];
	turn.completeTurn();
	_completedTurnIdx++;
}

public function get isAtEnd():Boolean{
	return _completedTurnIdx == (turns.length-1) && stackedActions.length == 0;
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
			var turn:GameTurn = ASRecord.findOrCreate(GameTurn,item.id) as GameTurn;
			item.actions = actionsThisTurn;
			turn.update(item);
			turns.addItem(turn);
			actionsThisTurn = [];
		}else{
			actionsThisTurn.push(item);
		}
	}
	unfinishedTurn = new GameTurn();
	unfinishedTurn.update({actions:actionsThisTurn});
	trace("got game data:" +rawHistory.length);
}

protected var continentBuilder:ContinentBuilder = new ContinentBuilder();
public function createLocations():void{
	var locationObjs:Array = [];
	for each(var tile:SphereShape in continentBuilder.tiles){
		var loc:Location = tile.dataItem;
		locationObjs.push(loc.toObject());
	}
	var params:Object = {gameId:this.id, locations:locationObjs};
	service.addEventListener(RequestQueueEvent.RESULT,onLocationsCreated);
	service.addRequest("create_locations","Play",params);
}
protected function onLocationsCreated(event:RequestQueueEvent):void{
	service.removeEventListener(RequestQueueEvent.RESULT,onLocationsCreated);
	getData();
}

public static function createGame():GameData{
	var game:GameData = new GameData();
	game.save();
	game.createLocations();
	return game;
}


}}