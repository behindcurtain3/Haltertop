class UsersController < ApplicationController
  # before_filters are run before anything else is done on the controller
  # Authenticate the user
  before_filter :authenticate,
    :except => [ :new, :create ]

  # Check for the correct user
  before_filter :correct_user,
    :only => [ :edit, :update ]

  # Check for admin
  before_filter :admin_user,
    :only => [ :destroy ]

  # Check if the user is already signed in
  before_filter :already_in,
    :only => [ :new, :create ]

  # GET /users
  def index
    @title = "Users"
    @users = User.all
  end

  # GET /users/#{id}
  def show
    @user = User.find(params[:id])
    @title = @user.name
		@friends = []

		if signed_in? && current_user?(@user) && @user.facebook?
			fb_friends = facebook_signed(current_user.token).get_connections("me", "friends")
			ids = []
			fb_friends.each do | friend |
				ids << friend['id']
			end

			# only query if ids have something
			if ids.length > 0
				@friends = User.find(:all, :limit => 8, :order => "random()", :conditions => ["fbid IN (?)", ids])
			end
		end
  end

  # GET /users/new
  def new
    @title = "Sign up"
    @user = User.new
  end

  # GET /users/#{id}/edit
  def edit
    @user = User.find(params[:id])
    @title = "Edit"
		
  end

  # POST /users
  def create
    @user = User.new(params[:user])

    # Attempt to save the new user
    if @user.save
      # if successful, sign them in & welcome them
      sign_in @user
      gflash :success => "Welcome!"
      redirect_to @user
    else
      # if not successful, blank the passwords so they aren't sent back
      @user.password = ''
      @user.password_confirmation = ''

			@user.errors.full_messages.each do |error|
				gflash :error => error
			end
			
      render :action => "new"
    end
  end

  # PUT /users/#{id}
  def update
    @user = User.find(params[:id])

    # Attempt to update attributes
    if @user.update_attributes(params[:user])
			gflash :success => "Settings saved."
			render :action => "show"
    else
      # if not successful re-render the edit page
      @title = "Edit"
      render :action => "edit"
    end
  end

  # DELETE /users/#{id}
  def destroy
    User.find(params[:id]).destroy
    gflash :success => "User terminated"
    redirect_to users_path
  end

  # Private methods
  private
    def correct_user
      @user = User.find(params[:id])

      # Redirect to home if they aren't the current user
      redirect_to root_path unless current_user?(@user)
    end

    def admin_user
      redirect_to root_path unless current_user.admin?
    end

    def already_in
      redirect_to root_path if signed_in?
    end

end