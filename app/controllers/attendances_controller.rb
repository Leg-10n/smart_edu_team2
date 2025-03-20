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
      p = params.permit(:student_id).merge(
        user_id: Current.user&.id,  # Prevent nil user error
        timestamp: Time.current
      )
      @attendance = Attendance.new(p)
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

    # Only allow a list of trusted parameters through.
    def attendance_params
      params.require(:attendance).permit(:student_id, :timestamp, :user_id)
    end
end
