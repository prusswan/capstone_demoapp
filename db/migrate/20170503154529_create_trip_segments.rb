class CreateTripSegments < ActiveRecord::Migration
  def change
    create_table :trip_segments do |t|
      t.integer :trip_id
      t.integer :position
      t.integer :image_id

      t.timestamps null: false
    end
  end
end
