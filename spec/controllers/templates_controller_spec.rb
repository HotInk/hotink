require 'spec_helper'

describe TemplatesController do
  before do
    @account = Factory(:account)
    @design = Factory(:design, :account => @account)
    @current_user = Factory(:user)
    @current_user.promote_to_admin
    controller.stub!(:current_user).and_return(@current_user)
  end

  describe "GET new" do
    it "should raise error if no role supplied" do
      lambda{ get :new, :account_id => @account.id, :design_id => @design.id  }.should raise_error(ArgumentError)
    end
    
    it "should build layout template" do
      get :new, :account_id => @account.id, :design_id => @design.id, :role => 'layout'
      should assign_to(:tplate).with_kind_of(Layout)
      should render_template(:new)
      should render_with_layout(:hotink)
    end
    
    it "should build partial template" do
      get :new, :account_id => @account.id, :design_id => @design.id, :role => 'partial'
      should assign_to(:tplate).with_kind_of(PartialTemplate)
      should render_template(:new)
    end
    
    it "should build front page template" do
      get :new, :account_id => @account.id, :design_id => @design.id, :role => 'front_page'
      should assign_to(:tplate).with_kind_of(FrontPageTemplate)
      should render_template(:new)
    end
  end
  
  describe "GET edit" do
    it "should load proper template" do
      template = Factory(:view_template, :design => @design)
      get :edit, :account_id => @account.id, :design_id => @design.id, :id => template.id
      should assign_to(:tplate).with(template)
    end    
  end
  
  describe "POST create" do
    it "should create layout template" do
      post :create, :account_id => @account.id, :design_id => @design.id, :layout => Factory.attributes_for(:layout, :design => @design)
      assigns[:tplate].should be_kind_of(Layout)
      should respond_with(:redirect)
    end
    
    it "should create partial template" do
      post :create, :account_id => @account.id, :design_id => @design.id, :partial_template => Factory.attributes_for(:partial_template,:design => @design)
      should assign_to(:tplate).with_kind_of(PartialTemplate)
      should respond_with(:redirect)
    end
    
    it "should create front page template" do
      post :create, :account_id => @account.id, :design_id => @design.id, :front_page_template => Factory.attributes_for(:front_page_template,:design => @design)
      should assign_to(:tplate).with_kind_of(FrontPageTemplate)
      should respond_with(:redirect)
    end
    
    it "should raise error on malformed template" do
       post :create, :account_id => @account.id, :design_id => @design.id, :partial_template => Factory.attributes_for(:partial_template, :code => "Bad code {% ", :design => @design)
       should render_template(:new)
       should set_the_flash
    end
  end
  
  describe "PUT update" do
     it "should save changes to a template" do
       template = Factory(:article_template, :design => @design)
       put :update, :account_id => @account.id, :design_id => @design.id, :id => template.id, :article_template => { :code => "New template code" }
       should set_the_flash
       should respond_with(:redirect)
     end

     it "should raise error on malformed template" do
       template = Factory(:article_template, :design => @design)
       put :update, :account_id => @account.id, :design_id => @design.id, :id => template.id, :article_template => { :code => "Bad code {% " }
       should render_template(:edit)
       should set_the_flash
     end
   end

   describe "DELETE destroy" do
     it "should delete template" do
       template = Factory(:view_template, :design => @design)
       delete :destroy, :account_id => @account.id, :design_id => @design.id, :id => template.id
       lambda { Template.find(template.id) }.should raise_error(ActiveRecord::RecordNotFound)
     end
   end
end
