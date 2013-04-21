package com.apptinic.util{
	
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;

public class ASRecordClass{
	
public static const ALL_DEFS:Dictionary = new Dictionary();
	
public var klass:Class;
public var superKlass:ASRecordClass;
public var className:String;
public var shortClassName:String;
public var remoteClassName:String;
public var tableBaseClass:Class;
public var associations:Object;
	
public function ASRecordClass(){
	
}
public static function getInstance(input:Class):ASRecordClass{
	var out:ASRecordClass = ALL_DEFS[input];
	if(!out){
		out = new ASRecordClass();
		out.klass = input;
		out.className = friendlyClassName(input);
		out.shortClassName = getShortClassName(input);
		out.tableBaseClass = out.klass;
		var sc:Class = getDefinitionByName(getQualifiedSuperclassName(input)) as Class;
		if(sc != ASRecord) out.superKlass = getInstance(sc);
		ALL_DEFS[input] = out;
	}
	
	return out;
}

public static function getShortClassName(input:*):String{
	var pkgs:Array = getQualifiedClassName(input).split(/::?/);
	return pkgs[pkgs.length-1];
}

protected var _assocByFKey:Object;
public function get assocByFKey():Object{
	if(!_assocByFKey){
		_assocByFKey = new Object();
		for(var s:String in associations) 
			_assocByFKey[associations[s].fKeyName] = associations[s];    
	}
	return _assocByFKey;
}

public static function friendlyClassName(input:*):String{
	// in some versions of AS, :: does funny things as part of an object key
	var out:String = getQualifiedClassName(input);
	return out.split("::").join(":");
}

public static var remoteClassFactoryDelegate:IASRecordRemoteClassConverter;
public static function createFromString(input:String):ASRecordClass{
	return remoteClassFactoryDelegate.getASRecordClass(input);
}


}}