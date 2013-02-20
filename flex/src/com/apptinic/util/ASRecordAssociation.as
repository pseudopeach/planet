package com.apptinic.util{
public class ASRecordAssociation{

public static const BELONGS_TO:String = "belongsTo";
public static const HAS_MANY:String = "hasMany";

public var _classInfo:ASRecordClass; // information about the associated class
public function get classInfo():ASRecordClass {return _classInfo;}
public function set assocClass(input:Class):void {_classInfo = ASRecordClass.getInstance(input);}
public var fKeyName:String; // property name of the foreign key (on whichever class)
public var type:String; // type of association
public var propName:String; // local property name
public var inversePropName:String;
protected var _inverse:ASRecordAssociation;

public function get inverse():ASRecordAssociation{
	if(!inversePropName) return null;
	if(!_inverse){
		_inverse = _classInfo.associations[inversePropName];
		if(!_inverse) throw new Error("Can't find specified property: "+inversePropName);
	}
	return _inverse;
}

public function ASRecordAssociation(input:Object=null){
	if(input){
		if(!(input.hasOwnProperty('assocClass') && input.hasOwnProperty('type')))
			throw new Error("Association must be created with, at a mnimum, an association type and a class.");
		for(var s:String in input)
			if(hasOwnProperty(s)) this[s] = input[s];
		
		if(!this.propName){
			propName = _classInfo.shortClassName
			propName = propName.charAt(0).toLowerCase() + propName.substr(1);
			if(type == HAS_MANY) propName += "s";
		}
		if(!fKeyName){
			fKeyName = (type == HAS_MANY) ? 
				_classInfo.shortClassName.charAt(0).toLocaleLowerCase() + 
					_classInfo.shortClassName.substr(1) :
				propName;
			fKeyName += "Id";
		}
		//trace("** created association: "+propName);
	}
}


}}