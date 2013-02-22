package com.apptinic.terraschema{
	import com.apptinic.util.ASRecord;
	import com.apptinic.util.UberCollection;
	
	import mx.collections.ArrayCollection;
	
[Bindable]
public class Player extends ASRecord{

public var name:String;
public var location:Location;
public var attributes:UberCollection;
//public var icon:Image;

public function Player(input:Object=null){
	super();
	enterInSchema(Player, [
		{type:BELONGS_TO, assocClass:Location},
		{type:HAS_MANY, propName:"attributes", assocClass:PlayerAttr, inversePropName:"player"},
	]);
	if(input) update(input);
}
	





}}