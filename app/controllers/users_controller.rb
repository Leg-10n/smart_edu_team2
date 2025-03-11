class UsersController < ApplicationController
    include Pagy::Backend
    def index
      # @users = User.all
      # if current_user.role == "admin"
      #   flash.notice = "is admin"
      # else
      #   flash.notice = "is not admin"
      # end
      flash.notice = current_user.role
      @pagy, @users = pagy(User.all)
    end

    # GET /users/1 or /users/1.json
    def show
      @user = User.all.find(params[:id]) # Fetch the user by ID from the database
      respond_to do |format|
        format.html { render "show" }
        format.js
        format.json { render json: @user.slice(:id, :created_at, :updated_at) }
      end
    end

    # GET /users/new
    def new
      @user = User.new
    end

    def edit
      @user = User.find(params[:id])
    end

    def create
      @user = User.new(user_params)

      respond_to do |format|
        if @user.save
          format.html { redirect_to @user, notice: "User was successfully created." }
          format.json { render :show, status: :created, location: @user }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
        @user = User.find(params[:id])

        # Detailed debugging
        logger.debug "User before update: #{@user.attributes.inspect}"
        logger.debug "User Params: #{params[:user]}"

        if @user.update(user_params)
          logger.debug "User after update: #{@user.attributes.inspect}"
          redirect_to users_path, notice: "User role updated successfully"
        else
          logger.debug "User update failed: #{@user.errors.full_messages}"
          render :edit
        end
    end

    private

    def user_params
      if current_user.role == "admin"
        params.require(:user).permit(:email_address, :password, :password_confirmation, :role)
        # params.require(:user).permit(:email_address, :password, :password_confirmation)
      else
        params.require(:user).permit(:email_address, :password, :password_confirmation)
      end
    end
end
