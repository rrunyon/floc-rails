# == Schema Information
#
# Table name: weeks
#
#  id              :bigint           not null, primary key
#  playoff         :boolean          default(FALSE), not null
#  recap           :text
#  week            :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  recap_author_id :bigint
#  season_id       :bigint           not null
#
# Indexes
#
#  index_weeks_on_recap_author_id     (recap_author_id)
#  index_weeks_on_season_id           (season_id)
#  index_weeks_on_week_and_season_id  (week,season_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (recap_author_id => teams.id)
#  fk_rails_...  (season_id => seasons.id)
#
class Week < ApplicationRecord
  belongs_to :season
end
