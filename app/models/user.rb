# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string
#  espn_raw   :jsonb            not null
#  first_name :string
#  last_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  espn_id    :string           not null
#
# Indexes
#
#  index_users_on_espn_id  (espn_id) UNIQUE
#
class User < ApplicationRecord
  has_many :teams

  def name
    [first_name, last_name].join(' ').titleize
  end
end
