require "test_helper"

class RivalriesTest < ActiveSupport::TestCase
  def setup
    @season = Season.create!(year: "2023")
    @week1 = Week.create!(season: @season, week: 1, playoff: false)
    @week2 = Week.create!(season: @season, week: 2, playoff: true)

    @user_a = User.create!(
      first_name: "Casey",
      last_name: "Gamma",
      email: "casey@example.com",
      espn_id: "u3",
      espn_raw: {}
    )
    @user_b = User.create!(
      first_name: "Dana",
      last_name: "Delta",
      email: "dana@example.com",
      espn_id: "u4",
      espn_raw: {}
    )

    @team_a = Team.create!(
      user: @user_a,
      season: @season,
      name: "Gamma Squad",
      espn_id: "t3",
      espn_raw: {
        "record" => { "overall" => { "wins" => 1, "losses" => 1, "pointsFor" => 200.0, "pointsAgainst" => 200.0 } },
        "transactionCounter" => { "acquisitions" => 2 }
      }
    )
    @team_b = Team.create!(
      user: @user_b,
      season: @season,
      name: "Delta Squad",
      espn_id: "t4",
      espn_raw: {
        "record" => { "overall" => { "wins" => 1, "losses" => 1, "pointsFor" => 200.0, "pointsAgainst" => 200.0 } },
        "transactionCounter" => { "acquisitions" => 2 }
      }
    )

    Matchup.create!(
      week: @week1,
      season: @season,
      home_team: @team_a,
      away_team: @team_b,
      home_score: 101.0,
      away_score: 99.0,
      playoff_tier_type: "NONE",
      espn_raw: {}
    )
    Matchup.create!(
      week: @week2,
      season: @season,
      home_team: @team_b,
      away_team: @team_a,
      home_score: 110.0,
      away_score: 95.0,
      playoff_tier_type: "WINNERS_BRACKET",
      espn_raw: {}
    )

    Matchup.create!(
      week: @week2,
      season: @season,
      home_team: @team_a,
      away_team: @team_b,
      home_score: 100.0,
      away_score: 100.0,
      playoff_tier_type: "NONE",
      espn_raw: {}
    )
  end

  test "filters regular season and playoffs" do
    regular = Stats::Rivalries.compute(filter: "regular")
    playoffs = Stats::Rivalries.compute(filter: "playoffs")

    assert_equal 2, regular[:top_rivalries].first[:games]
    assert_equal 1, playoffs[:top_rivalries].first[:games]
    assert_equal "Casey Gamma vs Dana Delta", regular[:top_rivalries].first[:key]
  end

  test "handles ties without errors" do
    regular = Stats::Rivalries.compute(filter: "regular")
    record = regular[:top_rivalries].first[:wins]

    assert_equal 1, record["Casey Gamma"]
    assert_equal 0, record["Dana Delta"]
  end
end
