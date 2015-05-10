class UsersController < ApplicationController

  def new
    @user = User.new

    render layout: false
  end

  def index
   @user = User.new
   if session[:user_id] != nil
      redirect_to user_groups_path(@current_user.id)
   end
  end

  def create
    if session[:user_id] != nil
      render :json => params
    else
      unless User.find_by_email(params[:user][:email])
        # unless params[:user][:picture] == nil
        uploaded_file = params[:user][:picture].path
        cloudinary_file = Cloudinary::Uploader.upload(uploaded_file)
        cloudinary_file = cloudinary_file["public_id"]
        # else
        # cloudinary_file = "assets/user_default.jpg"
        # cloudinary_file = Cloudinary::Uploader.upload(cloudinary_file)
        # end
        @user = User.create :firstname => params[:user][:firstname], :lastname => params[:user][:lastname], :email => params[:user][:email], :tel => params[:user][:tel], :password => params[:user][:password], :image => cloudinary_file
        if @user.id
        session[:user_id] = @user.id
        redirect_to user_groups_path(@user.id)
        else
        render :plain => 'ERROR DICKHEAD'
        end
      else
        render :plain => 'ERROR DICKHEAD'
      end
    end
    # render :json => @user
    redirect_to user_groups_path(@user.id)
  end

  def destroy
    session[:user_id] = nil
    flash[:info] = 'you have been logged out'
    redirect_to root_path
  end

  def show
    @user = @current_user
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :tel, :password)
  end


end