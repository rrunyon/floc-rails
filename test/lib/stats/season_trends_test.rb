require "test_helper"

class SeasonTrendsTest < ActiveSupport::TestCase
  def setup
    @season = Season.create!(year: "2022")
    @week1 = Week.create!(season: @season, week: 1, playoff: false)
    @week2 = Week.create!(season: @season, week: 2, playoff: false)

    @user_a = User.create!(
      first_name: "Alex",
      last_name: "Alpha",
      email: "alex@example.com",
      espn_id: "u1",
      espn_raw: {}
    )
    @user_b = User.create!(
      first_name: "Blair",
      last_name: "Beta",
      email: "blair@example.com",
      espn_id: "u2",
      espn_raw: {}
    )

    @team_a = Team.create!(
      user: @user_a,
      season: @season,
      name: "Alpha Squad",
      espn_id: "t1",
      espn_raw: {
        "record" => { "overall" => { "wins" => 2, "losses" => 0, "pointsFor" => 220.0, "pointsAgainst" => 180.0 } },
        "transactionCounter" => { "acquisitions" => 3 }
      }
    )
    @team_b = Team.create!(
      user: @user_b,
      season: @season,
      name: "Beta Squad",
      espn_id: "t2",
      espn_raw: {
        "record" => { "overall" => { "wins" => 0, "losses" => 2, "pointsFor" => 180.0, "pointsAgainst" => 220.0 } },
        "transactionCounter" => { "acquisitions" => 1 }
      }
    )

    Matchup.create!(
      week: @week1,
      season: @season,
      home_team: @team_a,
      away_team: @team_b,
      home_score: 110.0,
      away_score: 90.0,
      playoff_tier_type: "NONE",
      espn_raw: {}
    )
    Matchup.create!(
      week: @week2,
      season: @season,
      home_team: @team_b,
      away_team: @team_a,
      home_score: 90.0,
      away_score: 110.0,
      playoff_tier_type: "NONE",
      espn_raw: {}
    )

    @season.update!(first_place: @team_a, last_place: @team_b)
  end

  test "computes season trends with placements and stddev" do
    trends = Stats::SeasonTrends.compute
    stats = trends[@user_a.name]

    assert_equal 2, stats[:totals][:wins]
    assert_equal 0, stats[:totals][:losses]
    assert_equal 1, stats[:placements][:first]
    assert_equal 0, stats[:placements][:last]
    assert_in_delta 0.0, stats[:seasons]["2022"][:score_stddev], 0.01
  end

  test "filters by user and season range" do
    trends = Stats::SeasonTrends.compute
    filtered = Stats::SeasonTrends.filter(trends, user: @user_b.name, from: "2022", to: "2022")

    assert_equal [@user_b.name], filtered.keys
    assert_equal ["2022"], filtered[@user_b.name][:seasons].keys
  end

  test "returns empty when filters exclude all seasons" do
    trends = Stats::SeasonTrends.compute
    filtered = Stats::SeasonTrends.filter(trends, user: @user_b.name, from: "2025", to: "2026")

    assert_equal({}, filtered)
  end
end
