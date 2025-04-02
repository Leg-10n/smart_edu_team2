# app/controllers/home_controller.rb

class HomeController < ApplicationController
  allow_unauthenticated_access only: [ :landing ]

  def landing
    # If you're already logged in, don't let them stay on landing page.
    redirect_to "/dashboard" and return if authenticated?

    # Otherwise, show the public landing page.
  end

  def dashboard
    # Must be logged in (the default via 'before_action :require_authentication')
    @student_count = Student.count
    @attendance_count = Attendance.count
    @last_checkin = Attendance.maximum(:timestamp)
  end
end
