class PlayController < ApplicationController
  respond_to :html, :amf
  #before_filter :check_session
  #before_filter :check_player, :except=>[:create, :join]
  
  def history
    game = Terra::GameState.find(params[:id])
    @history = {:events=>game.history_events(params[:after_turn].to_i)}
    unless params[:after_turn]
      @history[:originalPlayers] = (game.players - game.created_players).map{|q| q.to_hash}
      @history[:originalLocations] = (game.locations).map{|q| q.to_hash}
    end
    #@bs = @history.map {|q| {:id=>q[:id], :created_at=>q[:created_at]} }
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
    #@user = User.find(session[:user_id])
    @user = User.find(1)
    @game = Terra::GameState.create_game(@user)
    render :amf => {:game_id=>@game.id}
  end
  
  def create_locations
    @game = Terra::GameState.find_by_id(params[:game_id])
    raise "Game {params[:game_id]} not found." unless @game
    raise "Locations already exist for this game." if @game.locations.length > 0
    
    @locations_in = params[:locations]
    @retult = @game.create_locations @locations_in
    render :amf => {:success=>@retult}
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
