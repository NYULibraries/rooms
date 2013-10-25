class UsersController < ApplicationController
  load_and_authorize_resource
  respond_to :js, :html, :csv
  
  # GET /users
  def index
    @users = User.search(params[:q]).sorted(params[:sort], "lastname ASC").page(params[:page]).per(30)
    
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
    @user = User.new(params[:user])
    flash[:notice] = t('users.create.success') if @user.save
    
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
     
    flash[:notice] = t('users.update.success') if @user.update_attributes(params[:user])
    respond_with(@user)
  end
  
  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_with(@user)
  end
  
  # Implement sort column function for this model
  def sort_column
    super "User", "lastname"
  end
  helper_method :sort_column

end
