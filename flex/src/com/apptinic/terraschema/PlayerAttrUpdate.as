package com.apptinic.terraschema{
	import com.apptinic.util.ASRecord;
	import com.apptinic.util.UberCollection;
	
[Bindable]
public class PlayerAttrUpdate extends ASRecord{

public var value:Number;
public var attrName:String; //redundant
	
public var playerAttr:PlayerAttr;
public var action:Action;

public function PlayerAttrUpdate(input:Object=null){
	super();
	enterInSchema(PlayerAttrUpdate, [
		{type:BELONGS_TO, assocClass:PlayerAttr},
		{type:BELONGS_TO, assocClass:Action, inversePropName:"attrUpdates"},
	]);
	if(input) update(input);
}
	





}}