
  desc "Starts a game"
  task :starter do
    u1 = User.first
    u2 = User.last
    g = Terra::GameState.create_game u1
    g.join u2
    p1p = u1.prototyped_creatures.first
    p2p = u2.prototyped_creatures.first
    p2 = g.current_turn_taker
    p1 = g.real_players.first
    a = p2p.create_launch_action p2
    g.stack_action a
    g.resolve_action
  end

  
  