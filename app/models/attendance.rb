# == Schema Information
#
# Table name: attendances
#
#  id         :integer          not null, primary key
#  timestamp  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  student_id :integer
#  user_id    :integer          not null
#
# Indexes
#
#  index_attendances_on_student_id  (student_id)
#  index_attendances_on_user_id     (user_id)
#
# Foreign Keys
#
#  student_id  (student_id => students.id)
#  user_id     (user_id => users.id)
#
class Attendance < ApplicationRecord
  belongs_to :student
  belongs_to :user, optional: true
  validates :student_id, presence: true
end
