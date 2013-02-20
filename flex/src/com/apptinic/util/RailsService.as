package com.apptinic.util{
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.rpc.events.ResultEvent;

[Event(name=RESULT, type="com.apptinic.ResultEvent")]

public class RailsService extends EventDispatcher{
	
public static const RESULT:String = "result";
public static const FAULT:String = "fault";
	
protected const ENDPOINT:String;
protected var queue:Array = new Array();

public var controllerName:String;
public var maxSimultaniousRequests:uint=0;
	
public function RailsService(controller:String=null){
	super();
	if(source) this.controllerName = controller;
}

public function send(opName:String, params:Array=null, refObject:Object=null):uint{
	return 0;
}

protected function onResult(event:ResultEvent):void{
	var newEvent:com.apptinic.ResultEvent(RESULT);
	dispatchEvent(newEvent);
}

}}