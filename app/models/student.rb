
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
class Student < ApplicationRecord
  validates :name, presence: true, length: { minimum: 5, maximum: 20 }
  include Discard::Model
  before_save :set_default_uid

  private

  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def set_default_uid
    self.uid = SecureRandom.uuid if uid.blank?
  end
end
