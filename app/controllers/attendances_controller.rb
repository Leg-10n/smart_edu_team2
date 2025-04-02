class AttendancesController < ApplicationController
  before_action :require_teacher
  before_action :set_attendance, only: %i[show edit update destroy]
  include Pagy::Backend

  # GET /attendances or /attendances.json
  def index
    @pagy, @attendances = pagy(Attendance.all)
  end

  # GET /attendances/1 or /attendances/1.json
  def show
  end

  # GET /attendances/new
  def new
    @q = Student.ransack(params[:q])
    @students = @q.result(distinct: true)
    @attendances = Attendance.order(timestamp: :desc).limit(20).includes(:student)
    respond_to do |format|
      format.html # For normal page loads
      format.turbo_stream # For Turbo-powered live updates
    end
  end

  # GET /attendances/1/edit
  def edit
  end

  # POST /attendances or /attendances.json
  def create
    timezone = cookies[:timezone] || "UTC"
    Time.use_zone(timezone) do
      # Check if we have a direct attendance parameter
      if params[:attendance].present?
        @attendance = Attendance.new(attendance_params)
        @attendance.timestamp ||= Time.current
        @attendance.user_id = current_user.id
      else
        # Permit only the 'uid' parameter from the QR code scan
        permitted_params = params.permit(:uid)  # Expecting 'uid' from QR scan

        # Find the student by their UID
        student = Student.find_by(uid: permitted_params[:uid])

        # If no student found, show an error
        unless student
          Rails.logger.debug "Student not found for UID: #{permitted_params[:uid]}"
          return respond_to do |format|
            format.html { redirect_to new_attendance_path, alert: "Invalid QR code. Student not found." }
            format.json { render json: { error: "Invalid QR code. Student not found." }, status: :unprocessable_entity }
          end
        end

        # Create a new attendance record for the student
        @attendance = Attendance.new(
          student_id: student.id,  # Use student_id after finding the student by uid
          timestamp: Time.current,
          user_id: current_user.id  # Assuming you're using the current logged-in user
        )
      end

      # Save the attendance and respond accordingly

      if @attendance.save
        respond_to do |format|
          format.html { redirect_to new_attendance_path(request.parameters), notice: "Attendance recorded." }
          format.json { render json: { message: "Attendance successfully recorded." }, status: :created }
        end
      else
        respond_to do |format|
          format.html { redirect_to new_attendance_path(request.parameters), alert: "Failed to save attendance." }
          format.json { render json: { error: @attendance.errors.full_messages.to_sentence }, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /attendances/1 or /attendances/1.json
  def update
    respond_to do |format|
      if @attendance.update(attendance_params)
        format.html { redirect_to @attendance, notice: "Attendance was successfully updated." }
        format.json { render :show, status: :ok, location: @attendance }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attendances/1 or /attendances/1.json
  def destroy
    @attendance.destroy!

    respond_to do |format|
      format.html { redirect_to attendances_path, status: :see_other, notice: "Attendance was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_attendance
    @attendance = Attendance.find(params[:id])
  end


  def attendance_params
    params.require(:attendance).permit(:student_id, :timestamp, :user_id)
  end
end
