require 'net/http'

module Espn
  class Parser
    BASE_URL = "https://fantasy.espn.com/apis/v3/games/ffl/leagueHistory/831039?view=mTeam&view=mMatchupScore"

    def run
      debugger

      # upsert_members

      puts data
    end

    private

    def upsert_members
      members.values.each { |member| insert_member(member) }
    end

    def members
      data
        .flat_map { |o| o[:members] }
        .each_with_object({}) { |member, members| members[member[:id]] = member }
    end

    def parse_member(raw_member)

    end

    def seasons
      data.map { |o| o[:seasonId] }
    end

    def teams
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
