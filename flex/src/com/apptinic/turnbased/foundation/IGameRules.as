package com.apptinic.turnbased.foundation{
public interface ITurnOrderDelegate{

//return the winner of the game, or null if the game is still in progress
function isActionLegal(action:GameAction,state:GameState):Player;

}}