class AccountActivationsController < ApplicationController
  
   skip_before_filter :find_account #Since we're taling about creating accounts, there's no need to find the current one.
   before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  
   def new  
     render  
   end  

   def create  
       @user = User.create(params[:account_activation])  
       if @user
         @user.deliver_account_activation_instructions!  
         flash[:notice] = "New account created, activation instructions emailed"
         respond_to do |format|
           format.js
         end
       else  
         flash[:notice] = "No user was found with that email address"  
        render :action => :new  
       end  
   end 

    def edit
      @account = @user.account  
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
        return
      end
      @account.accepts_role "manager", @user
      flash[:notice] = "Welcome to Hot Ink!"
      redirect_to account_articles_url(@user.account)
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
