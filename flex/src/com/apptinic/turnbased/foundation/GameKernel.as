package com.apptinic.turnbased.foundation{
	
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.collections.ArrayCollection;

public class GameKernel extends EventDispatcher{
	
	
protected var players:ArrayCollection = new ArrayCollection();
protected var state:GameState;
	
public function GameKernel(target:IEventDispatcher=null){
	super(target);
}

//shared singleton
protected static var _shared:GameKernel;
public static function get shared():GameKernel{
	if(!_shared)
		_shared = new GameKernel();
	return _shared
}

public function init():void{
	currentPlayerInd = 0;
	state = new GameState();
}


protected var currentPlayerInd:int = 0;
public var currentPlayer:Player;
protected function advancePlayer():Player{
	currentPlayerInd = (currentPlayerInd+1) % players.length;
	currentPlayer = players[currentPlayerInd];
}

public function commitMove(move:GameMove):void{
	reactToMove(move);
	advancePlayer();
	currentPlayer.prmoptMove(state.filterForPlayer(player), null /* *** */);
}

protected function reactToMove(move:GameMove):void{
	
}


}}