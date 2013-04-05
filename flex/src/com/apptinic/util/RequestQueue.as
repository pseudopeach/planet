package com.apptinic.util{
	
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.Dictionary;

import mx.rpc.AbstractOperation;
import mx.rpc.AsyncToken;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

[Event(name=GenericObjectEvent.RESULT, type="com.apptinic.util.RequestQueueEvent")]
[Event(name=GenericObjectEvent.FAULT, type="com.apptinic.util.RequestQueueEvent")]

public class RequestQueue extends EventDispatcher{

public var endpoint:String = "/amf";
public var server:String = "http://localhost:3000";
public var destination:String = "RubyAMF";

public var maxConcurrentRequests:uint = 3;
//public var synchronized:Boolean = false; // develop later

protected var queue:Array;
protected var outstandingRequests:uint = 0;
protected var sharedRemote:RemoteObject;
protected var refObjectDict:Dictionary = new Dictionary();


public function RequestQueue(target:IEventDispatcher=null){
	super(target);
	queue = [];
}

public function addRequest(opName:String, opSrc:String, params:Object=null, refObject:Object=null):uint{
	queue.push({opName:opName, opSrc:opSrc, params:params, refObject:refObject});
	pokeQueue();
	return queue.length;
}

protected function executeRequest(req:Object):void{
	var ro:RemoteObject = getSpareRemote();
	ro.source = req.opSrc;
	
	var op:AbstractOperation = ro.getOperation(req.opName);
	var tok:AsyncToken = op.send(req.params);
	if(req.refObject) 
		refObjectDict[tok] = req.refObject;
	outstandingRequests++;
	
}

protected function onResult(event:ResultEvent):void{
	var e:RequestQueueEvent = new RequestQueueEvent(RequestQueueEvent.RESULT);
	var remote:RemoteObject = event.target as RemoteObject;
	var refObj:Object = refObjectDict[event.token];
	
	e.data = event.result;
	if(refObj){
		e.refObject = refObj;
		delete refObjectDict[event.token];
	}
	if(!sharedRemote)
		sharedRemote = remote;
	else{
		remote.removeEventListener(ResultEvent.RESULT,onResult);
		remote.removeEventListener(FaultEvent.FAULT, onFault);
	}
	
	outstandingRequests--;
	pokeQueue();
	dispatchEvent(e);
}

protected function onFault(event:FaultEvent):void{
	var e:RequestQueueEvent = new RequestQueueEvent(RequestQueueEvent.FAULT);
	var remote:RemoteObject = event.target as RemoteObject;
	var refObj:Object = refObjectDict[event.token];
	
	trace("fault returned");
	
	if(refObj){
		e.refObject = refObj;
		delete refObjectDict[event.token];
	}
	if(!sharedRemote)
		sharedRemote = remote;
	
	outstandingRequests--;
	pokeQueue();
	dispatchEvent(e);
}

protected function pokeQueue():void{
	if(queue.length > 0 && maxConcurrentRequests - outstandingRequests > 0){
		//get a request from the queue, if there's room
		var request:Object = queue.shift();
		executeRequest(request);
	}
}

protected function getSpareRemote():RemoteObject{
	var remote:RemoteObject;
	if(sharedRemote){
		remote = sharedRemote;
		sharedRemote = null;
		return remote;
	}
	remote = new RemoteObject();
	remote.endpoint = server+endpoint;
	remote.destination = destination;
	remote.addEventListener(ResultEvent.RESULT,onResult);
	remote.addEventListener(FaultEvent.FAULT, onFault);
	return remote;
}

}}