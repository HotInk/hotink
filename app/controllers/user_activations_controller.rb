class UserActivationsController < ApplicationController
  before_filter :require_no_user  
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]  
 
  def new  
    render  
  end  

  def create  
    @user = User.find_by_email(params[:email])  
    if @user  
      @user.deliver_activation_instructions!  
      flash[:notice] = "Instructions to reset your password have been emailed to you. " +  
      "Please check your email."  
      redirect_to root_url  
    else  
      flash[:notice] = "No user was found with that email address"  
      render :action => :new  
    end  
  end 
   
   def edit  
     render  
   end  

   def update  
     @user.password = params[:user][:password]  
     @user.password_confirmation = params[:user][:password_confirmation]  
     if @user.save  
       flash[:notice] = "Password successfully updated"  
       redirect_to account_url  
     else  
       render :action => :edit  
     end  
   end
   
   private  
   
   def load_user_using_perishable_token  
     # Make user activation url valid for 1 full day.
     @user = User.find_using_perishable_token(params[:id], 1.day)  
     unless @user  
       flash[:notice] = "We're sorry, but we could not locate your account. " +  
       "If you are having issues try copying and pasting the URL " +  
       "from your email into your browser or restarting the " +  
       "process."  
       redirect_to root_url  
     end
   end
   
end
