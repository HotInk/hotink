class PasswordResetsController < ApplicationController
  
  layout 'login'
  
  skip_before_filter :login_required #This is fine, since all the functions here are protected by email-address
  before_filter :load_user_using_perishable_token, :only => [ :edit, :update ]
    
   def create  
      @user = User.find_by_email(params[:email])  
      if @user  
        @user.deliver_password_reset_instructions!  
        flash[:notice] = "Instructions to reset your password have been emailed to you."
        render :action => :success
      else  
        flash[:notice] = "No user was found with that email address"  
        render :status => 404
      end  
   end
   
   def update
     @user.password = params[:user][:password]
     @user.password_confirmation = params[:user][:password_confirmation]
     if @user.save
       flash[:notice] = "Password successfully updated"
       redirect_to root_url
     else
       render :action => :edit
     end
   end
   
end
