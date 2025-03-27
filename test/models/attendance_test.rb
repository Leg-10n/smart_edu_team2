# == Schema Information
#
# Table name: attendances
#
#  id         :integer          not null, primary key
#  timestamp  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  student_id :integer          not null
#  user_id    :integer
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
require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
