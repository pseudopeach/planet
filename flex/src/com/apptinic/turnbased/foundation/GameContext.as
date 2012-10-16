package com.apptinic.turnbased.foundation{
public class GameContext{
	
public static const REGULAR_TURN:String = "REGULAR_TURN";
public static const RESPOND_STACK:String = "RESPOND_STACK";
public static const RESPOND_UNSTACK:String = "RESPOND_UNSTACK";
	
public var activeAction:GameAction;
public var hasResolved:Boolean;
public var status:String;
	
public function GameContext(state:GameState=null){
	
}

}}