require "rails_helper"

describe "#validation" do
  it "is not valid without a locality" do
    species_location = SpeciesLocation.create(scientific_name: "test name")
    expect(species_location).to_not be_valid
    expect(species_location.errors.full_messages).to eq(["Locality can't be blank"])
  end

  it "is not valid without a scientific name" do
    species_location = SpeciesLocation.create(locality: "test place")
    expect(species_location).to_not be_valid
    expect(species_location.errors.full_messages).to eq(["Scientific name can't be blank"])
  end

  it "is valid with a scientific name and locality" do
    species_location = SpeciesLocation.create(scientific_name: "test name", locality: "test place")
    expect(species_location).to be_valid
  end
end