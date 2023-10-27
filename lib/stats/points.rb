module Stats
  module Points

    # Returns a hashmap of user_name => { season_year: [pf, pa, pf/g, pa/g]}
    def self.compute

      # Calculate totals
      map = User.includes(teams: :season).each_with_object({}) do |user, map|
        name = user.name
        map[name] ||= { totals: { points_for: 0, points_against: 0 }, game_count: 0 }

        user.teams.each do |team|
          user = team.user.name
          season = team.season.year
          stats = team.espn_raw['record']['overall']
          game_count = stats['wins'] + stats['losses']
          map[name][:game_count] += game_count

          map[name][:totals][:points_for] += stats['pointsFor']
          map[name][:totals][:points_against] += stats['pointsAgainst']

          map[name][season] = {
            points_for: stats['pointsFor'],
            points_against: stats['pointsAgainst'],
            points_for_per_game: stats['pointsFor'] / game_count,
            points_against_per_game: stats['pointsAgainst'] / game_count
          }
        end
      end

      # Calculate averages
      map.each_value do |stats|
        stats[:averages] = {
          points_for_per_game: stats[:totals][:points_for] / stats[:game_count],
          points_against_per_game: stats[:totals][:points_against] / stats[:game_count]
        }
      end

      map
    end
  end
end
