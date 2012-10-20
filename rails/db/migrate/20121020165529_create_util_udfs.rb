class CreateUtilUdfs < ActiveRecord::Migration
  def change
    create_table :util_udfs do |t|

      t.timestamps
    end
  end
end
