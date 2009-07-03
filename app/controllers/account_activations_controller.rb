class AccountActivationsController < ApplicationController
  
   skip_before_filter :find_account #Since we're taling about creating accounts, there's no need to find the current one.
   skip_before_filter :login_or_oauth_required, :only => [:edit, :update]
   before_filter :load_user_using_perishable_token, :only => [:edit, :update]
   before_filter :check_user_qualifications, :only => [:edit, :update]
  
   permit "admin", :only => [:create, :destroy]
  
   
   # The create function parses the user input to make sure it's a simple email address, then behaves in a number of different
   # ways, depending on whether or not the user already exists or not.
   def create
     begin
       raise ArgumentError unless params[:account_activation] && params[:account_activation][:email] && params[:account_activation][:email].strip.match(/^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+(?:[A-Z]{2}|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum)$/i)
       @user = User.find_by_email!(params[:account_activation][:email])
       @user.account = nil # attr_protected keeps account_id safe from mass assignment
       @user.deliver_account_activation_instructions!
       flash[:account_activation_notice] = "Account invitation emailed"
     
     rescue ArgumentError
       flash[:account_activation_notice] = "Sorry, can't work with that. It's not an email address."
    
     rescue ActiveRecord::RecordNotFound => new_account_user # Catch brand new users, raised by User.find_by_email
       @user = User.new(params[:account_activation])  
       if @user.save_as_inactive(false)
         @user.deliver_account_activation_instructions!
         flash[:account_activation_notice] = "Account invitation emailed"
       else
         flash[:account_activation_notice] = "Error sending email"
       end
    
     ensure
        @accounts = Account.find(:all)
        @account_activations = User.find(:all, :conditions => { :account_id => nil })
        render :partial => 'accounts/accounts_window' 
     end  
   end 

   def edit
      render :layout => 'login'
    end  

   def update
      
      @account = Account.new(params[:account])
            
      # An manager and an account must both be created for the system to work.
      # We do this in a transaction. Transactions only work if an error is both raised
      # and caught before it stops the action from processing.
      begin        
        ActiveRecord::Base.transaction do
          @account.save!
          @user.account = @account
          @user.update_attributes!(params[:user])
        end
      rescue ActiveRecord::RecordInvalid => invalid
        render :action=>"edit", :layout=>'login'
      else
        @account.accepts_role "manager", @user
        @account.accepts_role "staff", @user
        flash[:notice] = "Welcome to Hot Ink!"
        redirect_to account_articles_url(@user.account)
      end
    end

    # A no complaints ajax destroy function
    def destroy
      begin     
        @user = User.find(params[:id])
        @user.destroy
        flash[:notice] = "Invitation revoked"
      rescue
        flash[:notice] = "Error: Invitation NOT revoked"
      ensure
        @accounts = Account.find(:all)
        @account_activations = User.find(:all, :conditions => { :account_id => nil })
        render :partial => 'accounts/accounts_window'
      end
    end

    private  
    
    #Catch sneaky new existing-account users who want their own accounts.
    def check_user_qualifications
      redirect_to edit_user_activation_url(@user.perishable_token) and return if @user.account
    end

  
end
