require 'spec_helper'

describe DesignsController do
  before do
    @account = Factory(:account)
    
    @current_user = Factory(:user)
    @current_user.promote_to_admin
    controller.stub!(:current_user).and_return(@current_user)
  end

  describe "GET index" do
    before do
      @designs = (1..3).collect{ Factory(:design, :account => @account) }
      get :index, :account_id => @account.id
    end
    
    it { should assign_to(:designs).with(@designs) }
    it { should respond_with(:success) }
    it { should respond_with_content_type(:html) }
  end

  describe "GET show" do
    before do
      @design = Factory(:design, :account => @account)
      get :show, :account_id => @account.id, :id => @design.id
    end
    
    it { should assign_to(:design).with(@design) }
    it { should respond_with(:success) }
    it { should respond_with_content_type(:html) }
  end
    
  describe "GET to current_design" do
    context "with current design" do
      before do
        @design = Factory(:design, :account => @account)
        @account.update_attribute :current_design, @design
        get :current_design, :account_id => @account.id
      end
      
      it { should assign_to(:design).with(@design) }
      it { should respond_with(:success) }
      it { should respond_with_content_type(:html) }
    end
    
    context "without current design" do
      before do
        get :current_design, :account_id => @account.id
      end
      
      it { should_not assign_to(:design) }
      it { should respond_with(:success) }
      it { should respond_with_content_type(:html) }
    end
  end
  
    
  describe "GET new" do
    before do
      get :new, :account_id => @account.id
    end
    
    it { should assign_to(:design).with_kind_of(Design) }
    it { should respond_with(:success) }
    it { should respond_with_content_type(:html) }
  end
  
  describe "GET edit" do
    before do
      @design = Factory(:design, :account => @account)
      get :edit, :account_id => @account.id, :id => @design.id
    end
    
    it { should assign_to(:design).with(@design) }
    it { should respond_with(:success) }
    it { should respond_with_content_type(:html) }
  end

  describe "POST create" do
    context "with valid attributes" do
      before do
        post :create, :account_id => @account.id, :design => { :name => "Another new design" }
      end
    
      it "should create a design for the current account" do
        should assign_to(:design).with_kind_of(Design)
        assigns(:design).account.should == @account
      end
      it { should respond_with(:redirect) }
      it { should set_the_flash.to(/success/) }
    end
    
    context "without valid attributes" do
      before do
        post :create, :account_id => @account.id, :design => { :name => "" }
      end
    
      it "should not create a design for the current account" do
        should assign_to(:design).with_kind_of(Design)
        assigns(:design).should be_new_record
      end
      it { should respond_with(:success) }
      it { should render_template(:new) }
    end
  end
  
  describe "PUT update" do
    context "with valid attributes" do
      before do
        design_attributes = Factory.attributes_for(:design, :name => "Test success?")
        @design = Factory(:design, :account => @account)
        put :update, :account_id => @account.id, :id => @design.id, :design => design_attributes
      end
    
      it { should assign_to(:design).with_kind_of(Design) }
      it { should respond_with(:redirect) }
      it "should update the design" do
        assigns(:design).name.should eql("Test success?")
      end
    end
    
    context "without valid attributes" do
      before do
        design_attributes = Factory.attributes_for(:design, :name => "")
        @design = Factory(:design, :account => @account)
        
        put :update, :account_id => @account.id, :id => @design.id, :design => design_attributes
      end
    
      it { should assign_to(:design).with(@design) }
      it { should respond_with(:success) }
      it { should render_template(:edit) }
    end
  end
  
  describe "DELETE destroy" do
    before do
      @design = Factory(:design, :account => @account)
      delete :destroy, :account_id => @account.id, :id => @design.id
    end
    
    it "should delete the front page" do
      lambda{ Design.find(@design.id)}.should raise_error(ActiveRecord::RecordNotFound)
    end
    it { should respond_with(:redirect) }
  end
end
