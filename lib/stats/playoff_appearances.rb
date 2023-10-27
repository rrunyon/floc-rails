module Stats
  module PlayoffAppearances

    # Returns a hashmap of season => user, user => count for playoff appearances
    def self.compute
      matchups = Matchup.playoffs.includes(:season, home_team: :user, away_team: :user)

      # Build list users making the playoff each season
      map = matchups.each_with_object({}) do |matchup, map|
        year = matchup.season.year
        map[year] ||= Set.new

        map[year] << matchup.home_team.user.name
        map[year] << matchup.away_team.user.name
      end

      # Initialize total appearances by user
      map[:total_appearances] = {}
      User.all.each do |user|
        map[:total_appearances][user.name] = 0
      end

      # Compute total appearances by user
      Season.pluck(:year).each do |year|
        map[year].each do |user|
          map[:total_appearances][user] += 1
        end
      end

      map
    end
  end
end
