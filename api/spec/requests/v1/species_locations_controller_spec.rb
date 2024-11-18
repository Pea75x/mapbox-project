require 'rails_helper'

describe V1::SpeciesLocationsController, type: :request do
  let!(:species_location_1) { SpeciesLocation.create(locality: "place1", scientific_name: "name1", scientific_name_id: 1) }
  let!(:species_location_2) { SpeciesLocation.create(locality: "place1", scientific_name: "name2", scientific_name_id: 2) }
  let!(:species_location_3) { SpeciesLocation.create(locality: "place2", scientific_name: "name2", scientific_name_id: 2) }
  let(:params) { }

  before do
    request.call
  end

  describe "#find_locations" do
    let(:request) { -> { post "/v1/species_locations/find_locations", params: { scientific_name_id: params }}}

    context "with incorrect scientific name ID" do
      let(:params) { 3 }

      it "returns 404" do
        expect(@response).to have_http_status(:not_found)
      end
    end

    context "with scientific name ID with multiple locations" do
      let(:params) { 2 }

      it "returns an array with 2 records" do
        expect(@response).to have_http_status(:ok)
        expect(@response.parsed_body.count).to eq(2)
      end
    end
  end

    describe "#find_species" do
    let(:request) { -> { post "/v1/species_locations/find_species", params: { locality: params }}}

    context "with incorrect scientific name ID" do
      let(:params) { "unknown place" }

      it "returns 404" do
        expect(@response).to have_http_status(:not_found)
      end
    end

    context "with scientific name ID with a location" do
      let(:params) { "place2" }

      it "returns an array with 1 record" do
        expect(@response).to have_http_status(:ok)
        expect(@response.parsed_body.count).to eq(1)
      end
    end
  end
end