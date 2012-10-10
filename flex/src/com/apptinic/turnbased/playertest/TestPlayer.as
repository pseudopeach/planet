package com.apptinic.turnbased.playertest{
import com.apptinic.turnbased.foundation.GameAction;
import com.apptinic.turnbased.foundation.GameContext;
import com.apptinic.turnbased.foundation.GameKernel;
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

override public function prompt(state:GameState):void{
	var con:GameContext = new GameContext(state);
	var mv:GameAction;
	switch(name){
		case "Justin":
			if(con.status = GameContext.REGULAR_TURN && !logHas("move1")){
				mv = new GameAction();
				mv.name = "move1";
				log.push("move1");
				GameKernel.shared.commitAction(mv);
			}
			if(con.status = GameContext.RESPOND_STACK && logHas("resp1") && !logHas("resp2")){
				mv = new GameAction();
				mv.name = "resp2";
				log.push("resp2");
				GameKernel.shared.commitAction(mv);
			}
			return;
		case "Kyle":
			if(con.status = GameContext.RESPOND_STACK && logHas("move1") && !logHas("resp1")){
				mv = new GameAction();
				mv.name = "resp1";
				log.push("resp1");
				GameKernel.shared.commitAction(mv);
			}
			if(con.status = GameContext.REGULAR_TURN && logHas("move1") && !logHas("move2")){
				mv = new GameAction();
				mv.name = "move2";
				log.push("move2");
				GameKernel.shared.commitAction(mv);
			}
			return;
		case "Sarah":
			if(con.status = GameContext.RESPOND_UNSTACK && !logHas("resolved1")){
				mv = new GameAction();
				mv.name = "resolved1";
				log.push("resolved1");
				GameKernel.shared.commitAction(mv);
			}
			return;
	}
	GameKernel.shared.commitPassAction();
}

}}