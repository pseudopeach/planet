class Terra::CreatureUpgrade < ActiveRecord::Base
  has_many :creature_attributes, :foreign_key=>"crupgrade_id", :conditions => {:of_base_creature=>false}
end
