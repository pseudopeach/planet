package com.apptinic.util{
import flash.events.Event;

public class ASRecordEvent extends Event{

public static const CHANGE:String = "change";
public static const COLL_ITEM_ADDED:String = "collAdd";
public static const COLL_ITEM_REMOVED:String = "collRem";
public static const COLL_REORDER:String = "collRdr";
//public static const COLL_REMOVE_ALL:String = "collRAll";

public var subtype:String;
public var originalDispatcher:Object;
public var oldIndex:int;
public var newIndex:int;
public var item:Object;

protected static var uid:int = 1;
public var eventId:int;

public function ASRecordEvent(type:String, dispatcher:Object, otherEvent:ASRecordEvent=null){
	super(type, false, true);
	if(!otherEvent){
		eventId = uid;
		originalDispatcher = dispatcher;
		uid++;
	}else{
		eventId = otherEvent.eventId;
		originalDispatcher = otherEvent.originalDispatcher;
	}
}


}}