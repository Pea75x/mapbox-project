# frozen_string_literal: true

# @see https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  namespace :v1 do
    resources :species_locations, only: [] do
      collection do
        post :search_locality
        post :search_scientific_name
      end
    end
  end
end
