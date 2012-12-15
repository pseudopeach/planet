class Terra::BaseCreature < ActiveRecord::Base
  has_many :creature_attributes, :foreign_key=>"crupgrade_id", :conditions => {:of_base_creature=>true}
  
  def create_player_instance(owner, name="", upgrades=[])
    player = player_class.constantize.new
    attrs = {}
    player.transaction do
      player.engineering_cost = self.engineering_cost
      player.launch_cost = self.launch_cost
      
      creature_attributes.each do |q|
        attrs[q.name] = q.value
      end
      
      pxd = {}
      pxd[:blueprint] = {}
      pxd[:blueprint][:base] = self.id
      pxd[:blueprint][:upgrades] = []
      
      player.user = owner
      player.name = name
      player.save
      
      upgrades.each do |q|
        q.creature_attributes.each do |r|
          if attrs.key?(r.name)
            attrs[r.name] += r.value
          else
            attrs[r.name] = r.value
          end
        end #upgrade attribute
        player.engineering_cost += q.engineering_cost
        player.launch_cost += q.launch_cost
        pxd[:blueprint][:upgrades] << q.id
      end #upgrade
      
      player.game_attrs = attrs
      player.xdata = pxd
      player.save
    end #trans
    
  end
  
end
