package com.apptinic.util{
import flash.events.Event;

public class RequestQueueEvent extends Event{

public static const RESULT:String = "result";
public static const FAULT:String = "fault";

public var data:Object;
public var refObject:Object;


public function RequestQueueEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
	super(type, bubbles, cancelable);
}


}}