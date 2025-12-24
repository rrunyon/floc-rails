require "test_helper"

class TransactionsTest < ActiveSupport::TestCase
  def setup
    @season = Season.create!(year: "2021")
    @user = User.create!(
      first_name: "Evan",
      last_name: "Echo",
      email: "evan@example.com",
      espn_id: "u5",
      espn_raw: {}
    )

    Team.create!(
      user: @user,
      season: @season,
      name: "Echo Squad",
      espn_id: "t5",
      espn_raw: {
        "record" => { "overall" => { "wins" => 3, "losses" => 1, "pointsFor" => 300.0, "pointsAgainst" => 250.0 } },
        "transactionCounter" => { "acquisitions" => 7 }
      }
    )
  end

  test "computes transactions totals and averages" do
    transactions = Stats::Transactions.compute
    stats = transactions[:users][@user.name]

    assert_equal 7, stats[:total]
    assert_equal 7, stats[:seasons]["2021"][:acquisitions]
    assert_in_delta 1.75, stats[:seasons]["2021"][:per_game], 0.01
  end
end
