module Stats
  module Recaps

    # Returns a hashmap of season => { week_id: user }, user => count
    def self.compute
      weeks = Week.where(playoff: false).includes(:season, matchups: { home_team: :user, away_team: :user })

      weeks.each_with_object({}) do |week, map|
        season = week.season.year

        map[season] ||= {}

        min_score = 1000
        min_team = nil

        week.matchups.each do |matchup|
          if matchup.home_score < min_score
            min_score = matchup.home_score
            min_team = matchup.home_team
          end

          if matchup.away_score < min_score
            min_score = matchup.away_score
            min_team = matchup.away_team
          end
        end

        map[season][week.week] = min_team.user.name
        map[min_team.user.name] ||= 0
        map[min_team.user.name] += 1
      end
    end
  end
end
