class Terra::PlayerObserver < ActiveRecord::Base
  belongs_to :player
  belongs_to :observer, :class_name=>"Game::Player", :foreign_key=>"observer_id"

end
