package com.apptinic.terraview{
	import com.apptinic.terraschema.GameData;
	import com.apptinic.terraschema.Location;
	import com.apptinic.util.ASRecordEvent;

public class ViewController{
	
protected var gameData:GameData;
protected var globe:Globe;
public function ViewController(model:GameData,view:Globe){
	gameData = model;
	
	gameData.addEventListener(GameData.EVENT_LOCATION_ADDED,onLocationAdded);
}

protected function onLocationAdded(event:ASRecordEvent):void{
	var location:Location = event.item as Location;
	globe.addLocation(location);
}

}}