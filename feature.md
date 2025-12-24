# Feature Plan: Season Trends + Rivalry/Records Dashboards

## Goals
- Add two new stats dashboards focused on (1) season-to-season trends and (2) rivalry/records.
- Reuse existing data in `Team.espn_raw`, `Matchup` scores, and `Season` placements.
- Keep views simple (tables + compact charts) to fit current layout and Bulma styling.

## Proposed Pages

### 1) Season Trends
A multi-section page showing longitudinal performance for each user.

**Sections**
- **Points For / Against Trend**: line chart per user across seasons.
- **Wins vs Points Scatter**: highlight over/under-performing seasons.
- **Consistency Index**: per-season score volatility by user (std-dev of weekly scores).
- **Season Summary Cards**: placements (1st/2nd/3rd/last) + win/loss record.

**Data Sources**
- `Team.espn_raw['record']['overall']` for wins, losses, pointsFor, pointsAgainst.
- `Matchup` scores grouped by team to compute weekly variance.
- `Season` placements (`first_place_id`, `second_place_id`, etc.).

**Aggregations (new)**
- `Stats::SeasonTrends`:
  - per user, per season: wins, losses, points_for, points_against, points_for_per_game
  - per user, per season: weekly_score_stddev (from matchups)
  - per user: multi-season averages + deltas

**View**
- `app/views/stats/season_trends.html.erb`
- Filter by user (select) and season range (simple list).

---

### 2) Rivalry & Records
Show best rivalries, streaks, and notable records.

**Sections**
- **Rivalry Matrix**: smaller head-to-head table with win %, total meetings.
- **Top Rivalries**: list of pairs with most games and closest win %.
- **Blowout & Nail-Biter Records**: biggest win margin and closest win.
- **Streaks**: longest win streak vs a specific opponent.

**Data Sources**
- `Matchup` scores + `home_team`/`away_team` + `week`/`season`.
- `User` names for display.

**Aggregations (new)**
- `Stats::Rivalries`:
  - per pair: games, wins, losses, win_pct, avg_margin
  - top rivalries: by games + closeness of win_pct
  - records: max margin, min margin (non-tie)
  - streaks: longest consecutive wins per pair

**View**
- `app/views/stats/rivalries.html.erb`
- Filters: regular/playoffs/all (reuse existing playoff_tier_type logic).

---

### 3) Transactions Activity
Show how active each manager is on waivers/trades and how that correlates with success.

**Sections**
- **Moves Leaderboard**: total acquisitions all-time + per-season bars.
- **Moves vs Wins Scatter**: show whether activity correlates with wins or points.
- **Most Active Seasons**: top single-season acquisition counts by user.

**Data Sources**
- `Team.espn_raw['transactionCounter']['acquisitions']` per season.
- `Team.espn_raw['record']['overall']` for wins/points context.

**Aggregations (new)**  
- `Stats::Transactions`:
  - per user: total acquisitions, per-season acquisitions
  - per season: top movers, league average
  - optional: normalized moves per game

**View**
- `app/views/stats/transactions.html.erb`
- Filter by season or all-time.

## Implementation Notes
- Add routes and controller actions in `StatsController`.
- Use existing sidebar partial and add tabs.
- Keep computations in `lib/stats/` and memoize if needed.
- Use simple table layouts first; add charting later if desired.

## Progress Tracker
- [x] Add aggregator for season trends (`Stats::SeasonTrends`) with PF/PA and consistency.
- [x] Add aggregator for rivalries/records (`Stats::Rivalries`) with top pairs + records.
- [x] Add aggregator for transactions activity (`Stats::Transactions`).
- [x] Wire routes + controller actions for new dashboards.
- [x] Add sidebar links for new dashboards.
- [x] Create baseline views for season trends, rivalries, and transactions.
- [x] Add rivalry filters (regular/playoffs/all) and compute datasets per filter.
- [x] Enhance rivalry UI: sortable table + clearer win% formatting.
- [x] Add season trend filters (user + season range) with UI controls.
- [x] Add lightweight visualizations (sparklines/bars) for trends and transactions.
- [x] Add summary cards (season placement + record) to trends page.
- [x] Add tests for new aggregators (basic sanity + edge cases for ties/empty).
- [x] Add overview landing page with season-lag notice and highlights.

## Milestones
1) Build aggregators (`Stats::SeasonTrends`, `Stats::Rivalries`, `Stats::Transactions`).
2) Add views + sidebar links + controller actions.
3) Iterate on visuals (chart helpers or CSS-only sparklines).
