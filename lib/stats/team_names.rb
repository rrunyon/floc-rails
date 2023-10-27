module Stats
  module TeamNames

    # Returns a hashmap of user_name => { season_year: team_name }
    def self.compute
      Team.includes(:season, :user).each_with_object({}) do |team, map|
        user = team.user.name
        year = team.season.year

        map[user] ||= {}
        map[user][year] = team.name
      end
    end
  end
end
