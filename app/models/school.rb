# == Schema Information
#
# Table name: schools
#
#  id          :integer          not null, primary key
#  school_name :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class School < ApplicationRecord
    normalizes :school_name, with: ->(e) { e.strip }
    validates :school_name, presence: true, uniqueness: true
end
