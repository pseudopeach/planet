package com.apptinic.turnbased.foundation{
	
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class MoveContext extends EventDispatcher{
	
public function MoveContext(target:IEventDispatcher=null){
	super(target);
}

}}