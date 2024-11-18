namespace :import do
  desc "Import data from CSV"
  task import_csv: :environment do
    require 'csv'
    
    CSV.foreach('lib/data/species_locations.csv', headers: true) do |row|
      SpeciesLocation.find_or_create_by(locality: row['locality'], scientific_name_id: row['scientificNameID'], scientific_name: row['scientificName'])
    end
    
    puts "Data imported successfully!"
  end
end