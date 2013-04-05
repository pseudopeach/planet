class PlayController < ApplicationController
  respond_to :html, :amf
  #before_filter :check_session
  #before_filter :check_player, :except=>[:create, :join]
  
  def history
    game = Terra::GameState.find(params[:id])
    @history = game.history
    @bs = @history.map {|q| {:id=>q[:id], :created_at=>q[:created_at]} }
    respond_to do |format|
      format.html
      format.amf {render :amf => @history}
    end
  end
  
  def launch
    @game = @player.game
    @action = Terra::ActLaunch.from_prototype(@player, params[:prototype], params[:location])
    manager = @game.manager #Game::Kernel
    @result = manager.resume_game(@action)
  end
  
  def create
    
  end
  
  def join
    
  end
  
  def resign
    
  end
  
  def test
    @obj = {:s=>"Justin", :i=>3}
    render :amf => @obj
  end
  
  protected
  
  def check_session
    unless session[:user_id]
      flash[:notice] = "Invalid session"
      redirect_to :controller=>:application, :action=>:api_error
      return false
    end
  end
  
  def check_player
    @player = Game::Player.find_by_id(params[:player])
    @user = player.user
    unless player.user.id == session[:user_id]
      flash[:notice] = "Invalid player"
      redirect_to :controller=>:application, :action=>:api_error
      return false
    end
  end
end
