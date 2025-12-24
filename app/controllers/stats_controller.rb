# frozen_string_literal: true

class StatsController < ApplicationController
  def index
    redirect_to overview_stats_path
  end

  def overview
    @season_years = Season.order(year: :desc).pluck(:year)
    @season_filter = params[:season].presence
    @latest_season = @season_years.first
    @selected_season = @season_filter || @latest_season
    @latest_season_label = @latest_season ? @latest_season.to_s : "N/A"
    @selected_season_label = @selected_season ? @selected_season.to_s : "N/A"

    points = Stats::Points.compute
    moves = Stats::Moves.compute
    playoff_appearances = Stats::PlayoffAppearances.compute
    high_low = Stats::HighLowScores.compute
    rivalries = Stats::Rivalries.compute(filter: "regular")

    @standings = Team.joins(:season)
                     .includes(:user)
                     .where(seasons: { year: @selected_season })
                     .map do |team|
      record = team.espn_raw["record"]["overall"]
      {
        user: team.user.name,
        wins: record["wins"],
        losses: record["losses"],
        points_for: record["pointsFor"].to_f
      }
    end
    @standings = @standings.sort_by { |row| [-row[:wins], -row[:points_for]] }.first(5)

    @points_leaders = points.map do |user, stats|
      season_stats = stats[@selected_season]
      next unless season_stats
      { user: user, points_for: season_stats[:points_for].to_f }
    end.compact.sort_by { |row| -row[:points_for] }.first(5)

    @moves_leaders = moves.map do |user, stats|
      { user: user, total: stats[:total] }
    end.sort_by { |row| -row[:total] }.first(5)

    @playoff_leaders = playoff_appearances[:total].map do |user, count|
      { user: user, count: count }
    end.sort_by { |row| -row[:count] }.first(5)

    latest_week = high_low[@selected_season]&.keys&.max
    @weekly_high = latest_week ? high_low[@selected_season][latest_week][:high] : nil
    @weekly_low = latest_week ? high_low[@selected_season][latest_week][:low] : nil
    @latest_week_label = latest_week ? "Week #{latest_week}" : "N/A"

    @records = rivalries[:records]
  end

  def head_to_head
    @head_to_head = Stats::WinLossMatrix.compute
    @season_filter = params[:season]
    unless @season_filter.in?(%w[regular playoffs all consolation])
      @season_filter = "regular"
    end
    @sorted_users = User.all.sort_by(&:name)
  end

  def team_names
    @team_names = Stats::TeamNames.compute
  end

  def high_low_scores
    @high_low_scores = Stats::HighLowScores.compute
  end

  def season_trends
    @season_trends = Stats::SeasonTrends.compute
    @season_years = @season_trends.values.flat_map { |stats| stats[:seasons].keys }.uniq.sort
    @season_filter_user = params[:user]
    @season_filter_from = params[:from]
    @season_filter_to = params[:to]
    @season_trends_filtered = Stats::SeasonTrends.filter(
      @season_trends,
      user: @season_filter_user,
      from: @season_filter_from,
      to: @season_filter_to
    )
    @season_trends_max_pf = max_for(@season_trends_filtered, :points_for_per_game)
    @season_trends_max_pa = max_for(@season_trends_filtered, :points_against_per_game)
    @season_trends_max_stddev = max_for(@season_trends_filtered, :score_stddev)
  end

  def rivalries
    @season_filter = params[:season]
    unless @season_filter.in?(%w[regular playoffs all])
      @season_filter = "all"
    end
    @rivalries = Stats::Rivalries.compute(filter: @season_filter)
  end

  def transactions
    @transactions = Stats::Transactions.compute
    @transactions_max_total = @transactions[:users].values.map { |stats| stats[:total] }.max.to_i
    @transactions_max_season = @transactions[:users].values.flat_map do |stats|
      stats[:seasons].values.map { |season| season[:acquisitions] }
    end.max.to_i
    @transactions_max_per_game = @transactions[:users].values.flat_map do |stats|
      stats[:seasons].values.map { |season| season[:per_game] }
    end.max.to_f
    @transactions_max_avg_per_game = @transactions[:season_averages].values.map { |avg| avg[:per_game] }.max.to_f
  end

  private

  def max_for(trends, field)
    trends.values.flat_map do |stats|
      stats[:seasons].values.map { |season| season[field] }
    end.max.to_f
  end
end
