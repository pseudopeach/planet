package com.apptinic.turnbased.foundation{
public interface ITurnOrderDelegate{
	
function set state(input:GameState):void;
function setupPlayerOrder(initialTurnTaker:int = 0):void;
function stackWasResolved():void;
function get currentTurnTaker():Player;
function get currentResponder():Player;
function isActionSettled(action:GameAction):Boolean;

}}