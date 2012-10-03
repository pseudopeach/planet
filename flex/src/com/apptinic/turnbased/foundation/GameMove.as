package com.apptinic.turnbased.foundation{
	
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class GameMove extends EventDispatcher{
	
public function GameMove(target:IEventDispatcher=null){
	super(target);
}

}}