# == Schema Information
#
# Table name: students
#
#  id           :integer          not null, primary key
#  discarded_at :datetime
#  name         :string
#  uid          :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_students_on_discarded_at  (discarded_at)
#
require "test_helper"

class StudentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
