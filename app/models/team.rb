# == Schema Information
#
# Table name: teams
#
#  id         :bigint           not null, primary key
#  avatar_url :string
#  espn_raw   :jsonb            not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  espn_id    :string           not null
#  season_id  :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_teams_on_season_id              (season_id)
#  index_teams_on_user_id                (user_id)
#  index_teams_on_user_id_and_season_id  (user_id,season_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (season_id => seasons.id)
#  fk_rails_...  (user_id => users.id)
#
class Team < ApplicationRecord
  belongs_to :user
  belongs_to :season
end
