class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end

  def create
    user = User.authenticate(params[:session][:email], params[:session][:password])

    if user.nil?
      # Create an error message and re-render the signin form
			gflash :error => "There seems to be a problem with your email/password combination. Make sure they are correct!"
      render :action => "new"
    else
      # Sign the user in and redirect them
      sign_in user
      redirect_back_or user
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

	def redirect
		if params[:error]
			gflash :notice => "We were unable to link your facebook account."
			redirect_to root_path
		end

		token = facebook_token(params[:code]) if params[:code]
		session[:access_token] = token

		# needs to: check if token is avail...
		#		check if user w/ same email exists, if so update the users fbid
		#		if user doesn't exist create one, assign it a random password also
		# if no token return to root
		if token
			graph = facebook_signed(token)
			if graph.nil?
				gflash :error => "Unable to setup GraphAPI"
				redirect_to root_path
			end
			fbuser = graph.get_object('me')
			ouruser = User.find_by_email(fbuser['email'])

			if ouruser
				# set fbid if not already set
				if ouruser.fbid.nil?
					
					if ouruser.update_attribute(:fbid, fbuser['id'])
						gflash :success => "Thanks #{fbuser['first_name']}, your account is now linked with facebook."
					else
						gflash :error => "Unable to update account. #{ouruser.errors}"
					end
				end

				# update token
				if not ouruser.update_attribute(:token, token)
					gflash :error => "Unable to set access token"
				end

				redirect_to root_path
			else
				# create new user
				puts "User: #{fbuser}"
				puts "Email: #{fbuser['email']}"
				puts "ID: #{fbuser['id']}"
				ouruser = User.new
				ouruser.name = fbuser['name']
				ouruser.email = fbuser['email']
				ouruser.fbid = fbuser['id']
				ouruser.password = Time.now.utc
				ouruser.password_confirmation = ouruser.password
				ouruser.token = token
				if ouruser.save!
					gflash :success => "Welcome #{fbuser['first_name']}!"
					redirect_to root_path
				else
					gflash :error => "Unable to create acccount!"
					redirect_to root_path
				end
			end
		else
			gflash :error => "Sorry but we were unable to connect to your facebook account."
			redirect_to root_path
		end	

	end
end