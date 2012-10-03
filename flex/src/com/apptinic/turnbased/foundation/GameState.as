package com.apptinic.turnbased.foundation{
	
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class GameState extends EventDispatcher{
	
public function GameState(target:IEventDispatcher=null){
	super(target);
}

}}