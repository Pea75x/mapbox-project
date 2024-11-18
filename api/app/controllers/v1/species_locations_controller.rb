module V1
  class SpeciesLocationsController < ApplicationController
    def find_species
      @species_locations = SpeciesLocation.where(locality: params[:locality])

      if @species_locations.present?
        render json: @species_locations, status: :ok
      else
        render json: 'No species found for this location', status: 404
      end
    end

    def find_locations
      @species_locations = SpeciesLocation.where(scientific_name_id: params[:scientific_name_id])

      if @species_locations.present?
        render json: @species_locations, status: :ok
      else
        render json: 'No locations found for this species', status: 404
      end
    end
  end
end