class CreateTerraCreatureAttributes < ActiveRecord::Migration
  def change
    create_table :terra_creature_attributes do |t|

      t.timestamps
    end
  end
end
