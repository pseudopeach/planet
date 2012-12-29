class Terra::PlayerObserver < ActiveRecord::Base
  belongs_to :observed_player, :class_name=>"Game::Player", :foreign_key=>"player_id"
  belongs_to :observing_player, :class_name=>"Game::Player", :foreign_key=>"observer_id"

end
