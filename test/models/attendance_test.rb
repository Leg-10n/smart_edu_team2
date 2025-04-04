# == Schema Information
#
# Table name: attendances
#
#  id         :integer          not null, primary key
#  timestamp  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :integer
#  student_id :integer
#  user_id    :integer          not null
#
# Indexes
#
#  index_attendances_on_school_id   (school_id)
#  index_attendances_on_student_id  (student_id)
#  index_attendances_on_user_id     (user_id)
#
# Foreign Keys
#
#  school_id   (school_id => schools.id)
#  student_id  (student_id => students.id)
#  user_id     (user_id => users.id)
#
require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
