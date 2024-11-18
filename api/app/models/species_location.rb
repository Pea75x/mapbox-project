class SpeciesLocation < ApplicationRecord
  validates :locality, presence: true
  validates :scientific_name, presence: true, uniqueness: { scope: :locality }
end