module Stats
  module Moves

    # Returns a hashmap of user_name => { season_year: acquisitions }
    def self.compute
      User.includes(teams: :season).each_with_object({}) do |user, map|
        map[user.name] ||= { total: 0 }

        user.teams.each do |team|
          season = team.season.year
          count = team.espn_raw['transactionCounter']['acquisitions']
          map[user.name][season] = count

          map[user.name][:total] += count
        end
      end
    end
  end
end
