module Stats
  module GameDrama
    CLOSE_MARGIN = 5
    BLOWOUT_MARGIN = 25

    def self.compute
      games = []
      user_stats = Hash.new { |hash, key| hash[key] = default_user_stats }
      close_games_count = 0
      blowout_games_count = 0

      Matchup.includes(:week, :season, home_team: :user, away_team: :user).find_each do |matchup|
        next if matchup.home_score.nil? || matchup.away_score.nil?

        home_score = matchup.home_score.to_f
        away_score = matchup.away_score.to_f
        margin = (home_score - away_score).abs

        winner_team = home_score >= away_score ? matchup.home_team : matchup.away_team
        loser_team = winner_team == matchup.home_team ? matchup.away_team : matchup.home_team
        winner_score = [home_score, away_score].max
        loser_score = [home_score, away_score].min

        games << {
          season: matchup.season.year,
          week: matchup.week.week,
          margin: margin,
          winner: winner_team.user.name,
          loser: loser_team.user.name,
          winner_score: winner_score,
          loser_score: loser_score
        }

        close_games_count += 1 if margin <= CLOSE_MARGIN
        blowout_games_count += 1 if margin >= BLOWOUT_MARGIN

        update_user_stats(user_stats, matchup.home_team.user.name, home_score - away_score, margin)
        update_user_stats(user_stats, matchup.away_team.user.name, away_score - home_score, margin)
      end

      user_stats.each_value do |stats|
        stats[:average_margin] = stats[:games].positive? ? stats[:total_margin] / stats[:games] : 0.0
      end

      {
        close_threshold: CLOSE_MARGIN,
        blowout_threshold: BLOWOUT_MARGIN,
        games_count: games.size,
        close_games_count: close_games_count,
        blowout_games_count: blowout_games_count,
        nail_biters: games.sort_by { |game| game[:margin] }.first(5),
        blowouts: games.sort_by { |game| -game[:margin] }.first(5),
        drama_leaders: user_stats.map do |user, stats|
          {
            user: user,
            close_games: stats[:close_games],
            blowout_games: stats[:blowout_games],
            average_margin: stats[:average_margin]
          }
        end.sort_by { |row| [-row[:close_games], row[:average_margin]] }.first(5)
      }
    end

    def self.default_user_stats
      {
        close_games: 0,
        blowout_games: 0,
        total_margin: 0.0,
        games: 0,
        average_margin: 0.0
      }
    end

    def self.update_user_stats(user_stats, user_name, signed_margin, absolute_margin)
      stats = user_stats[user_name]
      stats[:games] += 1
      stats[:total_margin] += signed_margin
      stats[:close_games] += 1 if absolute_margin <= CLOSE_MARGIN
      stats[:blowout_games] += 1 if absolute_margin >= BLOWOUT_MARGIN
    end
  end
end
