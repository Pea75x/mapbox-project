module V1
  class SpeciesLocationsController < ApplicationController
    def search_locality
      @species_locations = SpeciesLocation.where(locality: params[:locality])

      if @species_locations.present?
        render json: @species_locations, status: :ok
      else
        render json: 'No species found for this location', status: 404
      end
    end

    def search_scientific_name
      @species_locations = SpeciesLocation.where(scientific_name: params[:scientific_name])

      if @species_locations.present?
        render json: @species_locations, status: :ok
      else
        render json: 'No locations found for this species', status: 404
      end
    end
  end
end