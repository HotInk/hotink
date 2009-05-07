class AccountActivationsController < ApplicationController
  
   skip_before_filter :find_account #Since we're taling about creating accounts, there's no need to find the current one.
   before_filter :load_user_using_perishable_token, :only => [:edit, :update]
   before_filter :check_user_qualifications, :only => [:edit, :update]
  
   permit "admin", :only => [:create, :destroy]
  

   def create  
       @user = User.new(params[:account_activation])  
       if @user.save_as_inactive(false)
         @user.deliver_account_activation_instructions!
         @accounts = Account.find(:all)
         @account_activations = User.find(:all, :conditions => { :account_id => nil })
         flash[:notice] = "New account created, activation instructions emailed"
         render :partial => 'accounts/accounts_window'
       else  
         flash[:notice] = "No user was found with that email address"  
        render :action => :new  
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
    
    #Catch sneaky new existing-account users who want their own accounts.
    def check_user_qualifications
      redirect_to edit_user_activation_url(@user.perishable_token) and return if @user.account
    end

  
end
