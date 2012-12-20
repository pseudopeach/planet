class Game::Location < ActiveRecord::Base
  belongs_to :game, :class_name=>"Game::State", :foreign_key=>"state_id"
  has_many :players
  
  def nearby_locations(radius=1,include_players=false)
    imax = i + radius
    imin = i - radius
    jmax = j + radius
    jmin = j - radius
    if include_players
      out = Game::Location.where("i <= ? and i >= ? and j <= ? and j >= ?",imax,imin,jmax,jmin).includes(:players)
    else
      out = Game::Location.where("i <= ? and i >= ? and j <= ? and j >= ?",imax,imin,jmax,jmin)
    end
    
    return out
  end
  
  def nearby_players(radius=1)
    locations = self.nearby_locations(radius).map {|q| q.id}
    players Game::Player.where(:location_id=>locations)
  end
  
  def range_to(loc)
    return (i-loc.i).abs+(j-loc.j).abs
  end
end