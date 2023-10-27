module Stats
  module WinLossMatrix

    # Returns a hashmap of win/loss records, team by team
    # {
    #   team1: {
    #     team2: {
    #       wins: 10,
    #       losses: 5
    #     }
    #   },
    #   team2: {
    #     team1: {
    #       wins: 5,
    #       losses: 10
    #     }
    #   }
    # }
    def self.compute
      matchups = Matchup.includes(home_team: :user, away_team: :user).all

      matchups.each_with_object({ regular_season: {}, playoffs: {} }) do |matchup, maps|
        map = matchup.regular_season? ? maps[:regular_season] : maps[:playoffs]
        home_user = matchup.home_team.user.name
        away_user = matchup.away_team.user.name
        map[home_user] ||= {}
        map[away_user] ||= {}
        map[home_user][away_user] ||= { win: 0, loss: 0 }
        map[away_user][home_user] ||= { win: 0, loss: 0 }


        if matchup.home_score > matchup.away_score
          map[home_user][away_user][:win] += 1
          map[away_user][home_user][:loss] += 1
        else
          map[away_user][home_user][:win] += 1
          map[home_user][away_user][:loss] += 1
        end
      end
    end
  end
end
