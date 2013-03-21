package com.apptinic.terraschema{

[Bindable]
public class ActMove extends Action{
	
public var newLocation:Location;
	
public function ActMove(input:Object=null){
	super(input);
}

override public function execute(state:GameData):void{
	super.execute(state);	
	player.location = newLocation;
	_classInfo.tableBaseClass = _classInfo.superKlass.klass;
}


}}