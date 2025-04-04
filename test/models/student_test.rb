# == Schema Information
#
# Table name: students
#
#  id           :integer          not null, primary key
#  discarded_at :datetime
#  name         :string
#  uid          :string           not null
#  school_id    :integer
#
# Indexes
#
#  index_students_on_discarded_at  (discarded_at)
#  index_students_on_school_id     (school_id)
#
# Foreign Keys
#
#  school_id  (school_id => schools.id)
#
require "test_helper"

class StudentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
