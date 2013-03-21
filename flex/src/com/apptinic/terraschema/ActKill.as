package com.apptinic.terraschema{

public class ActKill extends Action{
	
	
public function ActKill(input:Object=null){
	super(input);
}

override public function execute(state:GameData):void{
	super.execute(state);	
	state.players.removeItem(targetPlayer);
	_classInfo.tableBaseClass = _classInfo.superKlass.klass;
}


}}