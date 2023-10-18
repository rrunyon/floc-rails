module Stats
  module HighLowScores

    # Returns a hashmap of each regular season week as the key, and the low/high scorers for
    # the week
    # Example:
    # {
    #   1: {
    #     high: {
    #       user:
    #       score:
    #     },
    #     low: {
    #       user:
    #       score:
    #     }
    #   }
    # }
    def self.compute
      high_low_scores = Hash.new { |h, k| h[k] = [] }
      weeks = Week.where(playoff: false).includes(matchups: {home_team: :user, away_team: :user })
      weeks.each do |week|
        min_score = 1000
        max_score = 0
        min_team = nil
        max_team = nil

        week.matchups.each do |matchup|
          if matchup.home_score < min_score
            min_score = matchup.home_score
            min_team = matchup.home_team
          end

          if matchup.away_score < min_score
            min_score = matchup.away_score
            min_team = matchup.away_team
          end

          if matchup.home_score > max_score
            max_score = matchup.home_score
            max_team = matchup.home_team
          end

          if matchup.away_score > max_score
            max_score = matchup.away_score
            max_team = matchup.away_team
          end
        end

        high_low_scores[week.id] = {
          low: {
            user: min_team.user.name,
            score: min_score
          },
          high: {
            user: max_team.user.name,
            score: max_score
          }
        }
      end

      high_low_scores
    end
  end
end
