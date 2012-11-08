class CreateTerraCreatureUpgrades < ActiveRecord::Migration
  def change
    create_table :terra_creature_upgrades do |t|

      t.timestamps
    end
  end
end
