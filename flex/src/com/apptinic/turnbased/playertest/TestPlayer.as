package com.apptinic.turnbased.playertest{
import com.apptinic.turnbased.foundation.GameAction;
import com.apptinic.turnbased.foundation.GameContext;
import com.apptinic.turnbased.foundation.GameKernel;
import com.apptinic.turnbased.foundation.GameState;
import com.apptinic.turnbased.foundation.Player;

import flash.events.IEventDispatcher;

public class TestPlayer extends Player{
	
public static var log:Array = new Array();
	
public function TestPlayer(target:IEventDispatcher=null){
	super(target);
}

private function logHas(s:String):Boolean{
	return log.indexOf(s) != -1;
}

override public function prompt(state:GameState):GameAction{
	var mv:GameAction;
	switch(name){
		case "Justin":
			if(state.status == GameState.TURN_END && !logHas("move1")){
				mv = new GameAction();
				mv.name = "move1";
				log.push("move1");
				return mv;
			}
			if(state.status == GameState.ACTION_STACKED && logHas("resp1") && !logHas("resp2")){
				mv = new GameAction();
				mv.name = "resp2";
				log.push("resp2");
				return mv;
			}
			break;
		case "Kyle":
			if(state.status == GameState.ACTION_STACKED && logHas("move1") && !logHas("resp1")){
				mv = new GameAction();
				mv.name = "resp1";
				log.push("resp1");
				return mv;
			}
			if(state.status == GameState.TURN_END && logHas("move1") && !logHas("move2")){
				mv = new GameAction();
				mv.name = "move2";
				log.push("move2");
				return mv;
			}
			break;
		case "Sarah":
			if(state.status == GameState.ACTION_RESOLVED && !logHas("resolved1")){
				mv = new GameAction();
				mv.name = "resolved1";
				log.push("resolved1");
				return mv;
			}
			break;
	}
	return null;
}

}}