module SessionsHelper

  #
  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    self.current_user = user
  end

  # Sets @current_user
  def current_user=(user)
    @current_user = user
  end

  # Gets @current_user
  def current_user
    # set @current_user equal to the user corresponding to the remember token
    # only if @current_user is undefined.
    @current_user ||= user_from_remember_token
  end

  # is the user signed in?
  def signed_in?
    !current_user.nil?
  end

  # sign out a user
  def sign_out
		if session[:access_token]
			session[:access_token] = nil
			cookies.delete(:access_token)
		end
		if session[:remember_token]
	    cookies.delete(:remember_token)
		end
		self.current_user = nil
  end

  # checks if user is signed in
  def authenticate
    deny_access unless signed_in?
  end

  # redirects a to signin_path
  def deny_access
    store_location
    redirect_to signin_path, :notice => "Please sign in to access this page."
  end

  # is the @current_user the same as user?
  def current_user?(user)
    user == current_user
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end

	def facebook_signed(token)
		@graph ||= Koala::Facebook::GraphAPI.new(token)
	end

	def facebook_auth
		@oauth ||= Koala::Facebook::OAuth.new(auth_facebook_url)
	end

	def facebook_url
		Koala::Facebook::OAuth.new.url_for_oauth_code(:callback => auth_facebook_url, :permissions => [facebook_permissions])
	end

	def facebook_token(code)
		facebook_auth.get_access_token(code)
	end

	def facebook_permissions
		"email, offline_access"
	end

  private
    def user_from_remember_token
			# first try to access our user via fb token
			if session[:access_token]
				return User.find_by_token(session[:access_token])
			end

			# finally try normal authentication
			return User.authenticate_with_salt(*remember_token)
    end

    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end

    def store_location
      session[:return_to] = request.fullpath
    end

    def clear_return_to
      session[:return_to] = nil
    end
end