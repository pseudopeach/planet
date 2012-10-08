package com.apptinic.turnbased.foundation{
public interface IEndGameDelegate{

//return the winner of the game, or null if the game is still in progress
function getGameWinner(state:GameState):Player;

}}