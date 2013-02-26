class UsersController < ApplicationController
  before_filter :authenticate_admin
  
  # GET /users
  def index
    @users = User.search(params[:q]).sorted(params[:sort], "lastname ASC").page(params[:page]).per(30)
    
    respond_to do |format|
      format.html
      format.csv { render :csv => @users, :filename => "room_reservation_users.#{Time.now.strftime("%Y%m%d%H%m")}" }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  # GET /users/new
   def new
     @user = User.new
   end
  
  # POST /users
  def create
    @user = User.new
    @user.username = params[:user][:username]
    @user.email = params[:user][:email]
    @user.user_attributes = {}
    @user.user_attributes[:room_reserve_admin] = params[:user][:room_reserve_admin].to_i == 1

    respond_to do |format|
      if @user.save
        flash[:notice] = "Successfully created new user."
        format.html { redirect_to users_url }
      else
        format.html { render :new }
      end
    end
  end
  
  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # PUT /users/1
  def update
    @user = User.find(params[:id])
    user_attributes = {}
    user_attributes[:room_reserve_admin] = params[:user][:room_reserve_admin].to_i == 1
    @user.update_attributes(:user_attributes => user_attributes)

    respond_to do |format|
      flash[:notice] = "Updated user successfully."
      format.js { render :layout => false }
      format.html { redirect_to(@user) }
    end
  end
  
  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
    end
  end
  
  # Delete all non-admin users
  def clear_user_data
    User.destroy_all("user_attributes not like '%:room_reserve_admin: true%'")
    flash[:success] = "Successfully cleared inactive users."
    redirect_to users_url
  end
  
  # Implement sort column function for this model
  def sort_column
    super "User", "lastname"
  end
  helper_method :sort_column

end
