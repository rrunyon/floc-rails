module Stats
  module Recaps

    # Returns a hashmap of user id => recap count
    def self.compute
      recap_counts = Hash.new { |h, k| h[k] = [] }
      weeks = Week.where(playoff: false).includes(matchups: { home_team: :user, away_team: :user })

      weeks.each do |week|
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

        recap_counts[min_team.user.name] << week
      end

      recap_counts
    end
  end
end
