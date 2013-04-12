package com.apptinic.terraschema{

[Bindable]
public class ActMove extends Action{
	
public var newLocation:Location;
	
public function ActMove(input:Object=null){
	super();
	enterInSchema(ActMove, [
		{type:BELONGS_TO, propName:"newLocation", assocClass:Location}
	]);
	isBaseTableInherited = true;
	if(input) update(input);
}

override public function execute(state:GameData):void{
	super.execute(state);	
	player.location = newLocation;
	_classInfo.tableBaseClass = _classInfo.superKlass.klass;
}


}}