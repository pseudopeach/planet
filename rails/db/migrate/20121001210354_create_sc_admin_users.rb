class CreateScAdminUsers < ActiveRecord::Migration
  def change
    create_table :sc_admin_users do |t|

      t.timestamps
    end
  end
end
