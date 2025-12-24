# Repository Guidelines

## Project Structure & Module Organization
- `app/` holds Rails MVC code: controllers, models, views, helpers, jobs, mailers, and channels.
- `app/assets/` contains CSS and images; `app/javascript/` holds Stimulus controllers and importmap entrypoints.
- `config/` defines routes, environments, initializers, and storage settings.
- `db/` stores migrations and the SQL schema (`db/structure.sql`).
- `test/` contains Minitest suites organized by domain (`models`, `controllers`, `system`, etc.).
- `public/` is for static assets; `lib/` for shared code and rake tasks.

## Build, Test, and Development Commands
- `bin/setup` installs gems, prepares the database, clears temp files, and restarts the server.
- `bin/rails server` starts the app locally (default: http://localhost:3000).
- `bin/rails db:prepare` creates and migrates the database.
- `bin/rails test` runs the full Minitest suite.
- `bin/rails test test/models/user_test.rb` runs a single file.

## Coding Style & Naming Conventions
- Follow standard Rails conventions: 2-space indentation for Ruby/ERB, snake_case file names, and class/module names in CamelCase.
- Keep Stimulus controllers in `app/javascript/controllers` using `*_controller.js` names.
- Prefer small, focused methods and conventional Rails naming (e.g., `UsersController`, `User` model).

## Testing Guidelines
- Framework: Minitest with Rails test helpers (`test/test_helper.rb`).
- Name tests as `*_test.rb` and place them under the matching `test/` subdirectory.
- Add or update fixtures in `test/fixtures/` when model changes require data setup.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, and sentence-case (e.g., "Add matchup toggles").
- PRs should include a concise description, linked issue (if applicable), and UI screenshots for view changes.
- Agents should create a git commit at the end of each work session to make reverting easy.

## Configuration & Secrets
- Use `config/credentials.yml.enc` for secrets; avoid committing `.env` or raw keys.
- Storage adapters are configured in `config/storage.yml`; update credentials via `bin/rails credentials:edit`.
