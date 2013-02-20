package com.apptinic.util{
import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.collections.IList;

[Event(name=com.apptinic.util.ASRecordEvent.CHANGE, type="com.exp.util.ASRecordEvent")]
//[Event(name=com.apptinic.util.ASRecordEvent.COLL_ITEM_ADDED, type="com.exp.util.ASRecordEvent")]
//[Event(name=com.apptinic.util.ASRecordEvent.COLL_ITEM_REMOVED, type="com.exp.util.ASRecordEvent")]
//[Event(name=com.apptinic.util.ASRecordEvent.COLL_REORDER, type="com.exp.util.ASRecordEvent")]

public class UberCollection extends ArrayCollection{
	
public var supressEvents:Boolean = false;
public var refObject:Object;
	
public function UberCollection(source:Array=null){
	super(source);
}

override public function addItemAt(item:Object,index:int):void{
	super.addItemAt(item,index);
	if(!supressEvents){ 
		var event:ASRecordEvent = new ASRecordEvent(ASRecordEvent.CHANGE,this);
		event.subtype = ASRecordEvent.COLL_ITEM_ADDED;
		event.newIndex = index;
		dispatchEvent(event);
	}
}

override public function addAllAt(addList:IList, index:int):void{
	super.addAllAt(addList,index);
	var event:ASRecordEvent = new ASRecordEvent(ASRecordEvent.CHANGE,this);
	event.newIndex = index;
	dispatchEvent(event);
}

override public function removeItemAt(index:int):Object{
	var event:ASRecordEvent = new ASRecordEvent(ASRecordEvent.CHANGE,this);
	event.item = super.removeItemAt(index);
	if(!supressEvents){ 
		event.subtype = ASRecordEvent.COLL_ITEM_REMOVED;
		event.oldIndex = index;
		dispatchEvent(event);
	}
	return event.item;
}

public function removeItem(item:Object):Boolean{
	var ind:int;
	if((ind = this.source.indexOf(item)) == -1) return false;
	this.removeItemAt(ind);
	return true;
}

override public function removeAll():void{
	var event:ASRecordEvent;
	if(!supressEvents)
		for(var i:int=0;i<source.length;i++){
			event = new ASRecordEvent(ASRecordEvent.CHANGE,this);
			event.subtype = ASRecordEvent.COLL_ITEM_REMOVED;
			event.item = source[i];
			event.oldIndex = i;
			dispatchEvent(event);
		}
		
	super.removeAll();
	
	if(!supressEvents){
		event = new ASRecordEvent(ASRecordEvent.CHANGE,this);
		dispatchEvent(event);
	}
}

public function moveItemAt(oldIndex:int, newIndex:int):void{
	event.item = source[oldIndex];
	var d:int = newIndex >= oldIndex ? 1 : -1;
	for(var i:int=oldIndex;i<newIndex;i+=d)
		source[i] = source[i+d];
	source[newIndex] = event.item;
	if(!supressEvents){ 
		var event:ASRecordEvent = new ASRecordEvent(ASRecordEvent.CHANGE,this);
		event.subtype = ASRecordEvent.COLL_REORDER;
		event.oldIndex = oldIndex;
		event.newIndex = newIndex;
		dispatchEvent(event);
	}
}
public function findFirst(key:String, value:*):Object{
	var ind:int=0;
	while(ind<source.length && source[ind][key] != value) ind++;
	if(ind >= source.length) return null;
	return source[ind];
}
public function findLast(key:String, value:*):Object{
	var ind:int=source.length-1;
	while(ind>=0 && source[ind][key] != value) ind--;
	if(ind < 0) return null;
	return source[ind];
}

override public function refresh():Boolean{
	return true;
}



}}