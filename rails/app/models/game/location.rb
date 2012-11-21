class Game::Location < ActiveRecord::Base
  belongs_to :state
  has_many :players
  
  def nearby_locations(radius=1)
    imax = i + radius
    imin = i - radius
    jmax = j + radius
    jmin = j - radius
    saved = Game::Location.where("i <= ? and i >= ? and j <= ? and j >= ?",imax,imin,jmax,jmin)
    return saved - self
  end
  
  def has_player_type?(prototype_id)
    return players.where(:prototype_id=>prototype_id).length > 0
  end
end
