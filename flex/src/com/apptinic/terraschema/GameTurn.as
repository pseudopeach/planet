package com.apptinic.terraschema{
	import com.apptinic.util.ASRecord;
	import com.apptinic.util.UberCollection;
	
[Bindable]
public dynamic class GameTurn extends ASRecord{

public var createdAt:Date;

public var player:Player;
public var attrUpdates:UberCollection;
public var actions:UberCollection;


public function GameTurn(input:Object=null){
	super();
	enterInSchema(GameTurn, [
		{type:BELONGS_TO, assocClass:Player},
		{type:HAS_MANY, assocClass:Action},
		{type:HAS_MANY, propName:"attrUpdates", assocClass:PlayerAttrUpdate},
	]);
	if(input) update(input);
}

public function completeTurn():void{
	
}

public function doNextStep():void{
	
}

//**** implement execute()?
	
}}