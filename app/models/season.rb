# == Schema Information
#
# Table name: seasons
#
#  id              :bigint           not null, primary key
#  buy_in          :integer
#  payouts         :integer          is an Array
#  year            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  first_place_id  :bigint
#  last_place_id   :bigint
#  second_place_id :bigint
#  third_place_id  :bigint
#
# Indexes
#
#  index_seasons_on_first_place_id   (first_place_id)
#  index_seasons_on_last_place_id    (last_place_id)
#  index_seasons_on_second_place_id  (second_place_id)
#  index_seasons_on_third_place_id   (third_place_id)
#  index_seasons_on_year             (year) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (first_place_id => teams.id)
#  fk_rails_...  (last_place_id => teams.id)
#  fk_rails_...  (second_place_id => teams.id)
#  fk_rails_...  (third_place_id => teams.id)
#
class Season < ApplicationRecord
  has_many :weeks
  has_many :teams
end
