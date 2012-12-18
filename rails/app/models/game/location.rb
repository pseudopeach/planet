class Game::Location < ActiveRecord::Base
  belongs_to :game, :class_name=>"Game::State", :foreign_key=>"state_id"
  has_many :players
  
  def nearby_locations(radius=1)
    imax = i + radius
    imin = i - radius
    jmax = j + radius
    jmin = j - radius
    saved = Game::Location.where("i <= ? and i >= ? and j <= ? and j >= ?",imax,imin,jmax,jmin)
    return saved
  end
end