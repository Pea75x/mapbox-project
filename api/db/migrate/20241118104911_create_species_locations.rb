class CreateSpeciesLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :species_locations do |t|
      t.string :locality
      t.integer :scientific_name_id
      t.string :scientific_name
    end

    add_index :species_locations, :locality
    add_index :species_locations, :scientific_name_id
  end
end
