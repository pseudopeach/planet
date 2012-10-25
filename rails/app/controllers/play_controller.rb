class PlayController < ApplicationController
  
  def commit_move
    @game = Game::State.find_by_id(2)
    @action = SpecGameAction.new(params)
    manager = @game.manager #Game::Kernel
    @result = manager.resume_game(@action)
  end
end
