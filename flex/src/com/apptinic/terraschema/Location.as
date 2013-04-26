package com.apptinic.terraschema{
	import com.apptinic.util.ASRecord;
	import com.apptinic.util.UberCollection;
	
[Bindable]
public class Location extends ASRecord{

public var players:UberCollection;
public var i:int;
public var j:int;
public var terrainType:String;
public var coastSegments:Array = [];

//public var adjacentShapes:Vector.<SphereShape>;

public function Location(input:Object=null){
	super();
	enterInSchema(Location, [
		{type:HAS_MANY, assocClass:Player, inversePropName:"location"},
	]);
	if(input) update(input);
}
	





}}