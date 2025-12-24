module Stats
  module Transactions
    def self.compute
      map = {}
      per_season_totals = Hash.new(0)
      per_season_games = Hash.new(0)

      Team.includes(:user, :season).find_each do |team|
        name = team.user.name
        year = team.season.year
        acquisitions = team.espn_raw["transactionCounter"]["acquisitions"].to_i
        record = team.espn_raw["record"]["overall"]
        games = record["wins"].to_i + record["losses"].to_i

        map[name] ||= { total: 0, seasons: {} }
        map[name][:seasons][year] = {
          acquisitions: acquisitions,
          games: games,
          per_game: games.positive? ? acquisitions.to_f / games : 0.0
        }
        map[name][:total] += acquisitions

        per_season_totals[year] += acquisitions
        per_season_games[year] += games
      end

      season_averages = per_season_totals.each_with_object({}) do |(year, total), result|
        games = per_season_games[year]
        result[year] = {
          total: total,
          per_game: games.positive? ? total.to_f / games : 0.0
        }
      end

      top_seasons = []
      map.each do |name, stats|
        stats[:seasons].each do |year, season_stats|
          top_seasons << {
            user: name,
            season: year,
            acquisitions: season_stats[:acquisitions]
          }
        end
      end
      top_seasons.sort_by! { |entry| -entry[:acquisitions] }

      {
        users: map,
        season_averages: season_averages,
        top_seasons: top_seasons.first(10)
      }
    end
  end
end
