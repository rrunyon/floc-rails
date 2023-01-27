# == Schema Information
#
# Table name: matchups
#
#  id                :bigint           not null, primary key
#  away_score        :decimal(, )
#  espn_raw          :jsonb            not null
#  home_score        :decimal(, )
#  playoff_tier_type :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  away_team_id      :bigint           not null
#  home_team_id      :bigint           not null
#  season_id         :bigint           not null
#  week_id           :bigint           not null
#
# Indexes
#
#  index_matchups_on_away_team_id           (away_team_id)
#  index_matchups_on_home_team_id           (home_team_id)
#  index_matchups_on_season_id              (season_id)
#  index_matchups_on_week_id                (week_id)
#  index_matchups_on_week_season_and_teams  (week_id,season_id,home_team_id,away_team_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (away_team_id => teams.id)
#  fk_rails_...  (home_team_id => teams.id)
#  fk_rails_...  (season_id => seasons.id)
#  fk_rails_...  (week_id => weeks.id)
#
class Matchup < ApplicationRecord
  belongs_to :week
  belongs_to :season
  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"
end
