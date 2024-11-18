# frozen_string_literal: true

# @see https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  namespace :v1 do
    resources :species_locations, only: [] do
      collection do
        post :find_species
        post :find_locations
      end
    end
  end
end
