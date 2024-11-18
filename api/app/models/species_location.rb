class SpeciesLocation < ApplicationRecord
  validates :locality, presence: true
  validates :scientific_name_id, presence: true, uniqueness: { scope: :locality }
end