package com.apptinic.terraview{
import com.apptinic.terraschema.Action;
import com.apptinic.terraschema.GameData;

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