require 'net/http'

module Espn
  class Parser
    BASE_URL = "https://fantasy.espn.com/apis/v3/games/ffl/leagueHistory/831039?view=mTeam&view=mMatchupScore"

    def run
      insert_users
      insert_seasons
      insert_teams
      insert_weeks
      insert_matchups
      update_seasons_with_winners
      update_seasons_with_last_place
    end

    private

    # Look at the last two weeks of the season.
    # First place is winner of the WINNERS_BRACKET matchup from the final week
    # Second place is winner of the WINNERS_BRACKET matchup from the final week
    # Third place is the only winner of a WINNERS_CONSOLATION_BRACKET from the final week
    # that was the loser of a WINNERS_BRACKET matchup in the penultimate week
    def update_seasons_with_winners
      seasons = Season.includes(weeks: [:matchups])

      seasons.each do |season|
        penultimate_week, final_week = season.weeks.order(:week).last(2)

        final_week_championship_matchup = final_week.matchups.find { |m| m.playoff_tier_type == 'WINNERS_BRACKET' }
        if final_week_championship_matchup.home_score > final_week_championship_matchup.away_score
          season.first_place = final_week_championship_matchup.home_team
          season.second_place = final_week_championship_matchup.away_team
        else
          season.first_place = final_week_championship_matchup.away_team
          season.second_place = final_week_championship_matchup.home_team
        end

        penultimate_week_winners_consolation_winners = Set.new
        penultimate_week.matchups.select { |m| m.playoff_tier_type == 'WINNERS_BRACKET' }.each do |m|
          if m.home_score > m.away_score
            penultimate_week_winners_consolation_winners.add(m.away_team)
          else
            penultimate_week_winners_consolation_winners.add(m.home_team)
          end
        end

        final_week_winners_consolation_matchups = final_week.matchups.select { |m| m.playoff_tier_type == 'WINNERS_CONSOLATION_LADDER' }
        final_week_winners_consolation_matchups.each do |m|
          if m.home_score > m.away_score && penultimate_week_winners_consolation_winners.include?(m.home_team)
            season.third_place = m.home_team
          elsif m.home_score < m.away_score && penultimate_week_winners_consolation_winners.include?(m.away_team)
            season.third_place = m.away_team
          end
        end

        season.save!
      end
    end

    # TODO: Something still not right here, years with tiebreaks aren't working correctly
    def update_seasons_with_last_place
      data.each do |season|
        # If there is a tie here we need to tiebreak against lowest points scored, so collect all teams with the most 
        # losses to start
        teams = []
        most_losses = 0

        season[:teams].each do |team|
          losses = team[:record][:overall][:losses]
          points_for = team[:record][:overall][:pointsFor]

          if losses > most_losses
            most_losses = losses
            teams = [{ id: team[:id], points_for: }]
          elsif losses == most_losses
            teams << { id: team[:id], points_for: }
          end
        end

        last_place_id = teams.sort_by { |team| team[:points_for] }[0][:id]
        season_record = Season.find_by(year: season[:seasonId])
        last_place = Team.find_by(season: season_record, espn_id: last_place_id)
        season_record.update(last_place:)
      end
    end

    def insert_users
      records = users.map do |member|
        {
          espn_raw: member,
          espn_id: member[:id],
          first_name: member[:firstName],
          last_name: member[:lastName]
        }
      end

      User.insert_all(records)
    end

    def users
      data.flat_map { |s| s[:members] }
    end

    def insert_seasons
      records = seasons.map do |season|
        {
          year: season
        }
      end

      Season.insert_all(records)
    end

    def seasons
      data.map { |s| s[:seasonId] }
    end

    def insert_teams
      users_by_espn_id = User.all.index_by(&:espn_id)
      season_by_year = Season.all.index_by(&:year)

      records = teams_by_season.map do |season, teams|
        season_id = season_by_year[season].id

        teams.map do |team|
          user_id = users_by_espn_id[team[:primaryOwner]].id
          {
            season_id: season_id, 
            user_id: user_id,
            espn_raw: team,
            espn_id: team[:id],
            name: team[:name],
            avatar_url: team[:logo]
          }
        end
      end.flatten

      Team.insert_all(records)
    end

    def teams_by_season
      data.each_with_object({}) { |season, result| result[season[:seasonId].to_s] = season[:teams] }
    end

    def insert_weeks
      season_by_year = Season.all.index_by(&:year)

      records = weeks_by_season.map do |season, weeks|
        season_id = season_by_year[season].id
        weeks.map do |week|
          {
            season_id: season_id,
            week: week[:week],
            playoff: week[:playoff]
          }
        end
      end.flatten

      Week.insert_all(records)
    end
  
    def weeks_by_season
      result = {}

      data.each do |season|
        weeks = {} 

        season[:schedule].each do |matchup|
          week = matchup[:matchupPeriodId]
          playoff = matchup[:playoffTierType] != "NONE"

          weeks[week] ||= {
            week: week,
            playoff: playoff
          }
        end

        result[season[:seasonId].to_s] = weeks.values
      end

      result
    end

    def insert_matchups
      season_by_year = Season.all.index_by(&:year)

      teams_by_year = Team.includes(:season).all.group_by { |team| team.season.year }
      teams_by_year.each { |season, teams| teams_by_year[season] = teams.index_by(&:espn_id) }

      weeks_by_year = Week.includes(:season).all.group_by { |week| week.season.year }
      weeks_by_year.each { |season, weeks| weeks_by_year[season] = weeks.index_by(&:week) }

      records = []

      matchups_by_season.each do |season, matchups|
        season_id = season_by_year[season].id
        weeks = weeks_by_year[season]
        teams = teams_by_year[season]

        matchups.each do |matchup|
          week_id = weeks[matchup[:matchupPeriodId]].id
          home_team_id = teams[matchup[:home][:teamId].to_s].id

          # Something not right here, one matchup contains only a home team
          next if matchup[:away].blank?

          away_team_id = teams[matchup[:away][:teamId].to_s].id

          records << {
            espn_raw: matchup,
            week_id: week_id,
            season_id: season_id,
            home_team_id: home_team_id,
            away_team_id: away_team_id,
            home_score: matchup[:home][:totalPoints],
            away_score: matchup[:away][:totalPoints],
            playoff_tier_type: matchup[:playoffTierType]
          }
        end
      end

      Matchup.insert_all(records)
    end

    def matchups_by_season
      data.each_with_object({}) { |season, result| result[season[:seasonId].to_s] = season[:schedule] }
    end

    def data 
      @data ||= JSON.parse(fetch_json!, symbolize_names: true)
    end

    # Data fetched via this API returns an array of seasons. Each season contains the following keys:
    # "draftDetail",
    # "gameId",
    # "id",
    # "members",
    # "schedule",
    # "scoringPeriodId",
    # "seasonId",
    # "segmentId",
    # "status",
    # "teams"
    def fetch_json!
      Net::HTTP.get(URI(BASE_URL))
    end
  end
end
