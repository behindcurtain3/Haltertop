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
		session[:access_token] = Koala::Facebook::OAuth.new(auth_facebook_path).get_access_token(params[:code]) if params[:code]
		@oath = Koala::Facebook::OAuth.new(session[:access_token])
		@user = @oath.get_user_from_cookies(cookies)

		#redirect_to session[:access_token] ? success_path : failure_path
	end
end