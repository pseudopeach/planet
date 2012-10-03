package com.apptinic.util{
import flash.events.Event;

public class ObjectEvent extends Event{
	
public var obj:Object;
	
public function ObjectEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
	super(type, bubbles, cancelable);
}

}}