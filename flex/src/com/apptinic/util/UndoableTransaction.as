package com.apptinic.util{
public class UndoableTransaction{
	
public static const COLLECTION_ADDED_NEWVAL_AT_INDEX:String = "col_add";	
public static const COLLECTION_ADDED_NEWVALCOLLECTION_AT_INDEX:String = "col_add_multi";
public static const COLLECTION_REMOVED_OLDVAL_FROM_INDEX:String = "col_remove";
public static const COLLECTION_REMOVED_OLDVALCOLLECTION_FROM_FIRST_INDEX:String = "col_remove_multi";
public static const PROPERTY_OF_PARENT_CHANGED_FROM_OLDVAL_TO_NEWVAL:String = "prop_change";

// === accessor regex =======
//find
//public var (\w+):([\w\*]+)(.*)
/*
//replace with
private var _\1:\2\3 public function get \1():\2{return _\1;} [Bindable] public function set \1(input:\2):void{_\1 = input;}
*/

//02172012

public var parent:Object;
public var action:String;
public var oldValue:*;
public var newValue:*;
public var property:String;
public var index:int;
public var timeStamp:Date;
	
public function UndoableTransaction(act:String=null){
	timeStamp = new Date();
	if(act)
		action = act;
}

}}