package com.apptinic.terraschema{
	import com.apptinic.util.ASRecord;
	import com.apptinic.util.UberCollection;
	
[Bindable]
public class PlayerAttr extends ASRecord{

public var value:Number;
public var name:String;
	
public var player:Player;
public var attrUpdates:UberCollection;

public function PlayerAttr(input:Object=null){
	super();
	enterInSchema(PlayerAttr, [
		{type:HAS_MANY, propName:"attrUpdates", assocClass:PlayerAttrUpdate, inversePropName:"playerAttr"},
		{type:BELONGS_TO, assocClass:Player, inversePropName:"attributes"},
	]);
	if(input) update(input);
}
	





}}