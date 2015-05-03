class AddFlagsToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :admin, null: false
      t.string :name, limit: 256, null: true
      t.string :image, limit: 1024, null: true
    end
  end
end
