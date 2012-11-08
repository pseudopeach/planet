class CreateTerraActSpreads < ActiveRecord::Migration
  def change
    create_table :terra_act_spreads do |t|

      t.timestamps
    end
  end
end
