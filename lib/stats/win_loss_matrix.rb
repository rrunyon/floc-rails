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

      matchups.each_with_object({ regular_season: {}, playoffs: {}, mixed: {}, consolation: {} }) do |matchup, maps|
        target_maps = []
        if matchup.regular_season?
          target_maps << maps[:regular_season]
        elsif matchup.playoff_tier_type == "WINNERS_BRACKET"
          target_maps << maps[:playoffs]
        elsif matchup.playoff_tier_type.end_with?("CONSOLATION_LADDER")
          target_maps << maps[:consolation]
        end
        target_maps << maps[:mixed]
        home_user = matchup.home_team.user.name
        away_user = matchup.away_team.user.name

        target_maps.each do |target_map|
          target_map[home_user] ||= {}
          target_map[away_user] ||= {}
          target_map[home_user][away_user] ||= { win: 0, loss: 0 }
          target_map[away_user][home_user] ||= { win: 0, loss: 0 }
        end

        if matchup.home_score > matchup.away_score
          target_maps.each do |target_map|
            target_map[home_user][away_user][:win] += 1
            target_map[away_user][home_user][:loss] += 1
          end
        else
          target_maps.each do |target_map|
            target_map[away_user][home_user][:win] += 1
            target_map[home_user][away_user][:loss] += 1
          end
        end
      end
    end
  end
end
