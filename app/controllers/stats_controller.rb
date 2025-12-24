# frozen_string_literal: true

class StatsController < ApplicationController
  def index
    redirect_to head_to_head_stats_path
  end

  def head_to_head
    @head_to_head = Stats::WinLossMatrix.compute
    @season_filter = params[:season]
    unless @season_filter.in?(%w[regular playoffs all consolation])
      @season_filter = "regular"
    end
    @sorted_users = User.all.sort_by(&:name)
  end

  def recaps
    @recaps = Stats::Recaps.compute
  end

  def team_names
    @team_names = Stats::TeamNames.compute
  end

  def high_low_scores
    @high_low_scores = Stats::HighLowScores.compute
  end
end
