package com.apptinic.terraschema{
import com.apptinic.util.ASRecordClass;
import com.apptinic.util.IASRecordRemoteClassConverter;

import flash.utils.getDefinitionByName;

public class TerraRailsClassConverter implements IASRecordRemoteClassConverter{
	
public function TerraRailsClassConverter(){
	//declare every class that may be instanciated dynamically here
	var c01:ActLaunch;
	var c02:ActMove;
	var c03:ActKill;
	
}

public function getASRecordClass(input:String):ASRecordClass{
	var names:Array = input.split("::");
	input = "com.apptinic.terraschema."+names[names.length-1];
	if(!input)
		throw new Error("input class name was null!");
	var klass:Class = getDefinitionByName(input) as Class;
	if(!klass)
		throw new Error("Could not create a class from input str:"+input);
	return ASRecordClass.getInstance(klass);
}


}}