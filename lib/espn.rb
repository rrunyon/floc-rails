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
    end

    private

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
    end

    def matchups_by_season
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
