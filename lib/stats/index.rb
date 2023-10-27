module Stats
  module Index

    # Returns a master map of all stats
    def self.compute
      return {
        moves: Stats::Moves.compute,
        points: Stats::Points.compute,
        recaps: Stats::Recaps.compute,
        team_names: Stats::TeamNames.compute,
        win_loss_matrix: Stats::WinLossMatrix.compute,
        high_low_scores: Stats::HighLowScores.compute,
        playoff_appearances: Stats::PlayoffAppearances.compute
      }
    end
  end
end
