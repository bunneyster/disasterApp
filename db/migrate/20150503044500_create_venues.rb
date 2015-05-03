class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :name, limit: 128, null: false
      t.string :twx_name, limit: 256, null: true
      t.float :lat, null: false
      t.float :long, null: false
      t.string :address, limit: 128, null: true
      t.string :phone, limit: 32, null: true
      t.text :sensors, null: false, limit: 2.kilobytes
      t.index [:lat, :long], unique: true
    end
  end
end
