# frozen_string_literal: true

class StatsController < ApplicationController
  def index
    redirect_to recaps_stats_path
  end

  def recaps
    @recaps = Stats::Recaps.compute
  end
end
