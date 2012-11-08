class CreateTerraBaseCreatures < ActiveRecord::Migration
  def change
    create_table :terra_base_creatures do |t|

      t.timestamps
    end
  end
end
