package com.apptinic.turnbased.foundation{
public interface ITurnOrderDelegate{

function getNextTurnTaker(state:GameState):Player;
function getCurrentTurnTaker(state:GameState):Player;

function getNextResponder(state:GameState):Player;
function getCurrentResponder(state:GameState):Player;

}}