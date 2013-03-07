class AccessController < ApplicationController
  # This makes sure confirm_logged_in is called before the other actions
  # unless the actions are login, attempt_login, or logut
  before_filter :confirm_logged_in, :except => [:login, :attempt_login, :logout]
  
  def index
  	redirect_to(:controller => :csv_datasets)
  end

  def login
  	# login form
  end
  
  def attempt_login
  	# This receives the login form
  	authenticated_user = User.authenticate(params[:username], params[:password])
  	if authenticated_user
  		session[:user_id] = authenticated_user.id
  		session[:username] = authenticated_user.username
  		# flash message
  		flash[:notice] = "You have been successfully logged in."
  		# redirect
  		redirect_to(:action => 'index')
  	else
  		flash[:notice] = "Invalid username/password combination."
  		redirect_to(:action => 'login')
  	end
  	
  end
  
  def logout
  	session[:user_id] = nil # setting a value in a hash doesn't remove it, so why not delete?
  	session[:username] = nil
  	flash[:notice] = "You have been logged out"
  	redirect_to(:action => 'login')
  end
end
