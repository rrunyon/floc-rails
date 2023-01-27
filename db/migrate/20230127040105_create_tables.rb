class CreateTables < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.jsonb :espn_raw, null: false
      t.string :espn_id, null: false, index: { unique: true }

      t.string :first_name
      t.string :last_name
      t.string :email

      t.timestamps
    end

    create_table :teams do |t|
      t.jsonb :espn_raw, null: false
      t.string :espn_id, null: false

      t.references :user, foreign_key: true
      t.references :season

      t.string :name
      t.string :avatar_url

      t.timestamps
    end

    add_index :teams, [:user_id, :season_id], unique: true

    create_table :seasons do |t|
      t.string :year, null: false, index: { unique: true }

      t.references :first_place, foreign_key: { to_table: :teams }
      t.references :second_place, foreign_key: { to_table: :teams }
      t.references :third_place, foreign_key: { to_table: :teams }
      t.references :last_place, foreign_key: { to_table: :teams }

      t.integer :buy_in
      t.integer :payouts, array: true

      t.timestamps
    end

    # Add this after both tables exist
    add_foreign_key :teams, :seasons

    create_table :weeks do |t|
      t.references :season, foreign_key: true, null: false
      t.references :recap_author, foreign_key: { to_table: :teams }

      t.integer :week, null: false
      t.boolean :playoff, default: false, null: false
      t.text :recap

      t.timestamps
    end

    add_index :weeks, [:week, :season_id], unique: true

    create_table :matchups do |t|
      t.jsonb :espn_raw, null: false

      t.references :week, foreign_key: true
      t.references :season, foreign_key: true
      t.references :home_team, foreign_key: { to_table: :teams }
      t.references :away_team, foreign_key: { to_table: :teams }

      t.decimal :home_score
      t.decimal :away_score
      t.string :playoff_tier_type, null: false

      t.timestamps
    end

    add_index :matchups, [:week_id, :season_id, :home_team_id, :away_team_id], unique: true, name: :index_matchups_on_week_season_and_teams
  end
end
