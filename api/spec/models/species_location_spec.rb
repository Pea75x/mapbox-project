require "rails_helper"

describe "#validation" do
  it "is not valid without a locality" do
    species_location = SpeciesLocation.create(scientific_name_id: 2)
    expect(species_location).to_not be_valid
    expect(species_location.errors.full_messages).to eq(["Locality can't be blank"])
  end

  it "is not valid without a scientific name ID" do
    species_location = SpeciesLocation.create(locality: "place")
    expect(species_location).to_not be_valid
    expect(species_location.errors.full_messages).to eq(["Scientific name can't be blank"])
  end
end