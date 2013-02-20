package com.apptinic.terraschema{
	import com.apptinic.util.ASRecord;
	import com.apptinic.util.UberCollection;

public class Location extends ASRecord{

public var players:UberCollection;
public var i:int;
public var j:int;
public var isLand:Boolean = false;

public function Location(input:Object=null){
	super();
	enterInSchema(Location, [
		{type:HAS_MANY, assocClass:Player, inversePropName:"location"},
	]);
	if(input) update(input);
}
	





}}