package com.apptinic.util{
import flash.events.Event;

public class ServiceEvent extends Event{

public static const RESULT:String = "result";

public static var content:Object;


protected static var uid:int = 1;
public var eventId:int;

public function ServiceEvent(type:String){
	super(type);

}


}}