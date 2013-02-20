package com.apptinic.terraschema{
	import com.apptinic.util.ASRecord;
	import com.apptinic.util.UberCollection;
	
[Bindable]
public dynamic class Action extends ASRecord{

public var targetPlayer:Player;
public var player:Player;
public var attrUpdates:UberCollection;
public var xdata:Object;

public function Action(input:Object=null){
	super();
	enterInSchema(Action, [
		{type:BELONGS_TO, assocClass:Player},
		{type:BELONGS_TO, propName:"targetPlayer", assocClass:Player},
		{type:HAS_MANY, propName:"attrUpdates", assocClass:PlayerAttrUpdate},
	]);
	if(input) update(input);
}
	

public function execute(state:GameData):void{
	var au:PlayerAttrUpdate;
	for(var i:int=0;i<attrUpdates.length;i++){
		au = attrUpdates[i];
		if(!au.playerAttr.isPopulated)
			au.playerAttr.name = au.attrName;
		au.playerAttr.value = au.value;
	}
}



}}