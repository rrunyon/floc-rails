# frozen_string_literal: true

class StatsController < ApplicationController
  def index
    redirect_to head_to_head_stats_path
  end

  def head_to_head
    @head_to_head = Stats::WinLossMatrix.compute
    @sorted_users = User.all.sort_by(&:name)
  end

  def recaps
    @recaps = Stats::Recaps.compute
  end
end
