package com.apptinic.turnbased.foundation{
	
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class GameAction extends EventDispatcher{
	
public static const WAIT_FOR_HUMAN:String = "WAIT_FOR_HUMAN";
	
public var player:Player;
public var name:String
	
public function GameAction(target:IEventDispatcher=null){
	super(target);
}

public function resolve():void{
	
}

}}