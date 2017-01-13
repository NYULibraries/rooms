class UsersController < ApplicationController
  load_and_authorize_resource
  respond_to :js, :html, :csv

  # GET /users
  def index
    @users = User.sorted(params[:sort], "lastname ASC").page(params[:page]).per(30)
    @users = @users.with_query(params[:q]) unless params[:q].blank?

    respond_with(@users) do |format|
      format.csv { render :csv => @users, :filename => "room_reservation_users.#{Time.now.strftime("%Y%m%d%H%m")}" }
    end
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
    respond_with(@user)
  end

  # GET /users/new
   def new
     @user = User.new
     respond_with(@user)
   end

  # POST /users
  def create
    @user = User.new(user_params)
    flash[:success] = t('users.create.success') if @user.save

    respond_with(@user)
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    respond_with(@user)
  end

  # PUT /users/1
  def update
    @user = User.find(params[:id])

    flash[:success] = t('users.update.success') if @user.update_attributes(user_params)
    respond_with(@user)
  end

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_with(@user)
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, admin_roles: [])
  end

end
