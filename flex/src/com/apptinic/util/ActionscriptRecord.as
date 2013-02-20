package com.apptinic.util{
import avmplus.getQualifiedClassName;

import flash.events.EventDispatcher;
import flash.profiler.showRedrawRegions;
import flash.utils.Dictionary;
import flash.utils.describeType;
import flash.utils.getQualifiedClassName;

import flashx.textLayout.debug.assert;

public dynamic class ActionscriptRecord extends EventDispatcher{
//{type:MANY, assocClass:class, locProp:Object, fKeyName:"blabla_id", repo:Object
public static const HAS_MANY:String = "hasMany";
public static const BELONGS_TO:String = "belongsTo";
protected var id:String;
protected static var schema:Object;
//protected static var repository:Object;

public function ActionscriptRecord(){
	//if(!repository) repository = new Object();
	if(!schema) schema = new Object();
}

public function set schemaInfo(input:Array):void{
	var className:String = getQualifiedClassName(this);
	if(schema.hasOwnProperty(className)) return;
	for(var i:int;i<input.length;i++){
		if(!item.propName){
			item.propName = item.assocClass.shortClassName;
			if(item.type == HAS_MANY) item.propName += "s";
		}
		if(!item.fKeyName){
			item.fKeyName = (item.type == HAS_MANY) ? thisClassShortName : item.propName;
			item.fKeyName += "Id";
		}		
	}
}

public function populate(input:Object):void{
	var fkeyNames:Array;
	var assocNames:Array;
	for(var s:String in input){
		this[s] = input[s];
		if(assocNames.hasOwnProperty(s)){
			//update in repository
		}else if(fKeyNames.hasOwnProperty(s)){
			var assoc:Object = fKeyNames[s];
			var rec:Object;
			//search repository
			if(!input.hasOwnProperty(assoc.propName) && rec = getArchivedRecord(assoc.assocClass,input[s])
				this[assoc.propName] = rec;
		}		
	}
}

protected function setAssociatedObj(schemaItem:Object, record:ActionscriptRecord):void{
	
}
protected function setAssociatedId(schemaItem:Object, id:*):void{
	
}

protected static var _shortClassName:String;
public function get shortClassName():String{
	if(!_shortClassName){
		var pkgs:Array = getQualifiedClassName(this).split(".");
		_shortClassName = pkgs[pkgs.length-1];
	return _shortClassName;
}
protected static var thisClassShortName:String = "ThisClass";

}}