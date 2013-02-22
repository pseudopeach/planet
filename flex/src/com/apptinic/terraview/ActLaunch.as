package com.apptinic.terraview{
import com.apptinic.terraschema.Action;
import com.apptinic.terraschema.GameData;
import com.apptinic.terraschema.Player;
import com.apptinic.terraschema.PlayerAttrUpdate;
import com.apptinic.util.ASRecord;
import com.apptinic.util.ASRecordClass;
import com.apptinic.util.UberCollection;

[Bindable]
public class ActLaunch extends Action{
	
public var createdPlayer:Player;
	
public function ActLaunch(input:Object=null){
	super();
	enterInSchema(ActLaunch, [
		{type:BELONGS_TO, propName:"createdPlayer", assocClass:Player}
	]);
	_classInfo.tableBaseClass = _classInfo.superKlass.klass;
	if(input) update(input);
}

override public function execute(state:GameData):void{
	var createdPlayerId:int = this.xdata.createdPlayerId
	var createdPlayerClass:ASRecordClass = ASRecordClass.createFromString(this.xdata.createdPlayerClass);
	createdPlayer = ASRecord.findOrCreate(createdPlayerClass,createdPlayerId) as Player;
	state.players.addItem(createdPlayer);
	
	createdPlayer.attributes = new UberCollection();
	for(var i:int=0;i<attrUpdates.length;i++)
		createdPlayer.attributes.addItem(attrUpdates[i].playerAttr);
	
	super.execute(state);	
}


}}