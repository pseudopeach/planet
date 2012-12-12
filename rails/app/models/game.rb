module Game
  def self.table_name_prefix
    'game_'
  end
  
  GAME_CREATED = :created
  GAME_READY_FOR_PLAY = :ready_for_play
  PROMPTING_PLAYER = :prompting_player
  PLAYER_PASSED = :player_passed
  TURN_END = :turn_end
  ACTION_STACKED = :action_stacked
  ACTION_RESOLVED = :action_resolved
  GAME_OVER = :game_over
  
  #ALL_STATUSES = [GAME_INITIALIZED,PROMPTING_PLAYER,PLAYER_PASSED,TURN_END,ACTION_STACKED,ACTION_RESOLVED,GAME_OVER]
  
  OUTCOME_SINGLE_WINNER = :outcome_single_winner
  OUTCOME_DRAW = :outcome_draw
  
  ALL_OUTCOMES = [OUTCOME_SINGLE_WINNER,OUTCOME_DRAW]
end
