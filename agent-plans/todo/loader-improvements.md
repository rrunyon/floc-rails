# ESPN Loader Review Notes

## Findings (bugs/issues)
- Missing `Set` require: `update_seasons_with_winners` uses `Set` without `require 'set'`, which can raise `NameError` when the loader runs. (`lib/espn/loader.rb:40`)
- Byes dropped: `api-response.json` shows 2 matchups per season with no `away` team (weeks 14/15). The loader skips these (`next if matchup[:away].blank?`), so bye games never appear in `matchups`, which can skew stats derived from matchup counts. (`lib/espn/loader.rb:206-208`)
- Broken Team associations: `has_many :home` is invalid, and `has_many :matchups` is overridden by a method, disabling association features and eager loading. (`app/models/team.rb:30-34`)

## Improvements
- Make the loader idempotent: use `unique_by`/`upsert_all` for seasons, weeks, matchups, and teams so re-runs don’t violate unique indexes. (`lib/espn/loader.rb:113`, `lib/espn/loader.rb:140`, `lib/espn/loader.rb:161`, `lib/espn/loader.rb:224`)
- Add DB uniqueness on team identity per season, e.g. index `[:season_id, :espn_id]`, to prevent duplicates if data changes or the loader re-runs. (`db/migrate/20230127040105_create_tables.rb:14-28`)
- Guard `update_seasons_with_winners` for incomplete seasons (missing weeks or missing winners-bracket matchup) to avoid nil errors. (`lib/espn/loader.rb:29-37`)
- Model byes explicitly (nullable `away_team_id`, `bye` flag, or a separate table) instead of skipping them. (`db/migrate/20230127040105_create_tables.rb:59-75`, `lib/espn/loader.rb:206-219`)
