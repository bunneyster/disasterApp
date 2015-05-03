class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :name, limit: 128, null: false
      t.float :lat, null: false
      t.float :long, null: false
      t.text :sensors, null: false, limit: 2.kilobytes
      t.index [:lat, :long], unique: true
    end
  end
end
