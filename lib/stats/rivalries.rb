module Stats
  module Rivalries
    def self.compute(filter: "all")
      pairs = {}
      pair_matchups = Hash.new { |hash, key| hash[key] = [] }
      biggest_blowout = nil
      closest_game = nil

      matchups = Matchup.includes(:season, :week, home_team: :user, away_team: :user)
      matchups = apply_filter(matchups, filter)

      matchups.find_each do |matchup|
        home_user = matchup.home_team.user.name
        away_user = matchup.away_team.user.name
        sorted = [home_user, away_user].sort
        pair_key = sorted.join(" vs ")

        pairs[pair_key] ||= {
          users: sorted,
          games: 0,
          wins: Hash.new(0),
          margins: []
        }

        scores = { home: matchup.home_score.to_f, away: matchup.away_score.to_f }
        margin = (scores[:home] - scores[:away]).abs
        winner = scores[:home] > scores[:away] ? home_user : (scores[:away] > scores[:home] ? away_user : nil)
        loser = winner == home_user ? away_user : (winner == away_user ? home_user : nil)

        pairs[pair_key][:games] += 1
        pairs[pair_key][:wins][winner] += 1 if winner
        pairs[pair_key][:margins] << margin

        pair_matchups[pair_key] << {
          year: matchup.season.year.to_i,
          week: matchup.week.week,
          winner: winner,
          loser: loser
        }

        if winner && (biggest_blowout.nil? || margin > biggest_blowout[:margin])
          biggest_blowout = {
            winner: winner,
            loser: loser,
            margin: margin,
            season: matchup.season.year,
            week: matchup.week.week
          }
        end

        if winner && margin.positive? && (closest_game.nil? || margin < closest_game[:margin])
          closest_game = {
            winner: winner,
            loser: loser,
            margin: margin,
            season: matchup.season.year,
            week: matchup.week.week
          }
        end
      end

      pair_summaries = pairs.map do |pair_key, stats|
        user_a, user_b = stats[:users]
        wins_a = stats[:wins][user_a]
        wins_b = stats[:wins][user_b]
        games = stats[:games]
        avg_margin = stats[:margins].empty? ? 0.0 : stats[:margins].sum / stats[:margins].length
        win_pct_a = games.positive? ? wins_a.to_f / games : 0.0
        win_pct_b = games.positive? ? wins_b.to_f / games : 0.0

        {
          key: pair_key,
          users: stats[:users],
          games: games,
          wins: { user_a => wins_a, user_b => wins_b },
          win_pct: { user_a => win_pct_a, user_b => win_pct_b },
          avg_margin: avg_margin
        }
      end

      top_rivalries = pair_summaries.sort_by do |summary|
        win_pct_values = summary[:win_pct].values
        closeness = (win_pct_values[0] - win_pct_values[1]).abs
        [-summary[:games], closeness]
      end.first(10)

      streaks = compute_streaks(pair_matchups).first(10)

      {
        pairs: pair_summaries,
        top_rivalries: top_rivalries,
        records: {
          biggest_blowout: biggest_blowout,
          closest_game: closest_game
        },
        streaks: streaks
      }
    end

    def self.compute_streaks(pair_matchups)
      streaks = []

      pair_matchups.each do |pair_key, matchups|
        ordered = matchups.sort_by { |entry| [entry[:year], entry[:week]] }
        current = { winner: nil, streak: 0, start: nil }
        best = { winner: nil, loser: nil, streak: 0, start: nil, finish: nil }

        ordered.each do |entry|
          if entry[:winner].nil?
            current = { winner: nil, streak: 0, start: nil }
            next
          end

          if entry[:winner] == current[:winner]
            current[:streak] += 1
          else
            current = { winner: entry[:winner], streak: 1, start: entry }
          end

          if current[:streak] > best[:streak]
            best = {
              winner: current[:winner],
              loser: entry[:loser],
              streak: current[:streak],
              start: current[:start],
              finish: entry
            }
          end
        end

        next unless best[:streak].positive?

        streaks << {
          pair: pair_key,
          winner: best[:winner],
          loser: best[:loser],
          streak: best[:streak],
          from: format_label(best[:start]),
          to: format_label(best[:finish])
        }
      end

      streaks.sort_by { |entry| -entry[:streak] }
    end

    def self.format_label(entry)
      return nil unless entry

      "#{entry[:year]} W#{entry[:week]}"
    end

    def self.apply_filter(matchups, filter)
      case filter
      when "regular"
        matchups.where(playoff_tier_type: "NONE")
      when "playoffs"
        matchups.where(playoff_tier_type: "WINNERS_BRACKET")
      else
        matchups
      end
    end
  end
end
