module Stats
  module SeasonTrends
    def self.compute
      placements = placement_totals
      scores_by_team_id = Hash.new { |hash, key| hash[key] = [] }

      Matchup.includes(:season, :week, home_team: :user, away_team: :user).find_each do |matchup|
        scores_by_team_id[matchup.home_team_id] << matchup.home_score.to_f
        scores_by_team_id[matchup.away_team_id] << matchup.away_score.to_f
      end

      map = {}

      Team.includes(:user, :season).find_each do |team|
        name = team.user.name
        year = team.season.year
        record = team.espn_raw["record"]["overall"]
        wins = record["wins"]
        losses = record["losses"]
        games = wins + losses
        points_for = record["pointsFor"].to_f
        points_against = record["pointsAgainst"].to_f
        scores = scores_by_team_id[team.id]

        map[name] ||= {
          seasons: {},
          totals: { wins: 0, losses: 0, games: 0, points_for: 0.0, points_against: 0.0 }
        }

        map[name][:seasons][year] = {
          wins: wins,
          losses: losses,
          points_for: points_for,
          points_against: points_against,
          points_for_per_game: games.positive? ? points_for / games : 0.0,
          points_against_per_game: games.positive? ? points_against / games : 0.0,
          score_stddev: stddev(scores)
        }

        map[name][:totals][:wins] += wins
        map[name][:totals][:losses] += losses
        map[name][:totals][:games] += games
        map[name][:totals][:points_for] += points_for
        map[name][:totals][:points_against] += points_against
      end

      map.each_value do |stats|
        games = stats[:totals][:games]
        stats[:averages] = {
          points_for_per_game: games.positive? ? stats[:totals][:points_for] / games : 0.0,
          points_against_per_game: games.positive? ? stats[:totals][:points_against] / games : 0.0
        }
      end

      placements.each do |name, counts|
        map[name] ||= {
          seasons: {},
          totals: { wins: 0, losses: 0, games: 0, points_for: 0.0, points_against: 0.0 }
        }
        map[name][:placements] = counts
      end

      map
    end

    def self.filter(trends, user: nil, from: nil, to: nil)
      filtered = user.to_s.empty? ? trends : trends.slice(user)
      from_year = from.to_s.empty? ? nil : from.to_i
      to_year = to.to_s.empty? ? nil : to.to_i

      filtered.each_with_object({}) do |(name, stats), result|
        seasons = stats[:seasons].select do |season, _|
          year = season.to_i
          (from_year.nil? || year >= from_year) && (to_year.nil? || year <= to_year)
        end

        next if seasons.empty?

        totals = { wins: 0, losses: 0, games: 0, points_for: 0.0, points_against: 0.0 }
        seasons.each_value do |season_stats|
          wins = season_stats[:wins]
          losses = season_stats[:losses]
          totals[:wins] += wins
          totals[:losses] += losses
          totals[:games] += wins + losses
          totals[:points_for] += season_stats[:points_for]
          totals[:points_against] += season_stats[:points_against]
        end

        games = totals[:games]
        result[name] = {
          seasons: seasons,
          totals: totals,
          placements: stats[:placements],
          averages: {
            points_for_per_game: games.positive? ? totals[:points_for] / games : 0.0,
            points_against_per_game: games.positive? ? totals[:points_against] / games : 0.0
          }
        }
      end
    end

    def self.stddev(values)
      return 0.0 if values.length < 2

      mean = values.sum / values.length
      variance = values.sum { |value| (value - mean) ** 2 } / values.length
      Math.sqrt(variance)
    end

    def self.placement_totals
      totals = Hash.new { |hash, key| hash[key] = { first: 0, second: 0, third: 0, last: 0 } }

      Season.includes(first_place: :user, second_place: :user, third_place: :user, last_place: :user).find_each do |season|
        if season.first_place
          totals[season.first_place.user.name][:first] += 1
        end
        if season.second_place
          totals[season.second_place.user.name][:second] += 1
        end
        if season.third_place
          totals[season.third_place.user.name][:third] += 1
        end
        if season.last_place
          totals[season.last_place.user.name][:last] += 1
        end
      end

      totals
    end
  end
end
