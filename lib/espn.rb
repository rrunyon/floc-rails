require 'net/http'

module Espn
  class Parser
    BASE_URL = "https://fantasy.espn.com/apis/v3/games/ffl/leagueHistory/831039?view=mTeam&view=mMatchupScore"

    def run
      insert_users
      insert_seasons
      insert_teams
    end

    private

    def insert_users
      records = users.values.map do |member|
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
      data
        .flat_map { |s| s[:members] }
        .each_with_object({}) { |member, members| members[member[:id]] = member }
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
      user_ids_by_espn_id = User.all.each_with_object({}) { |user, h| h[user.espn_id] = user.id }

      debugger

      records = teams.map do |team|
        user_id = user_ids_by_espn_id[team[:primaryOwner]]
        {
          user_id: user_id,
          espn_raw: team,
          espn_id: team[:id],
          name: team[:name],
          avatar_url: team[:logo]
        }
      end

      Team.insert_all(records)
    end

    def teams
      data.map { |season| season[:teams] }.flatten
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
