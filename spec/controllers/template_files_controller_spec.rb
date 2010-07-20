require 'spec_helper'

describe TemplateFilesController do
  before do
    @account = Factory(:account)
    @design = Factory(:design, :account => @account)
    @current_user = Factory(:user)
    @current_user.promote_to_admin
    controller.stub!(:current_user).and_return(@current_user)
  end
  
  describe "GET new" do
     it "should respond to HTML" do
       get :new, :account_id => @account.id, :design_id => @design.id
       should respond_with(:success)
       should assign_to(:design).with(@design)
       should respond_with_content_type(:html)
       should render_with_layout(:hotink)
     end
  end
   
  describe "POST create" do
    describe "stylesheet" do
      before do
        post :create, :account_id => @account.id, :design_id => @design.id, :template_file => { :file => File.new(RAILS_ROOT + '/spec/fixtures/test_css.css') }
      end
      
      it { should assign_to(:template_file).with_kind_of(Stylesheet) }
      it { should respond_with(:redirect) }
    end
    
    describe "javscript files" do
      before do
        post :create, :account_id => @account.id, :design_id => @design.id, :template_file => { :file => File.new(RAILS_ROOT + '/spec/fixtures/test_js.js') }
      end
      
      it { should assign_to(:template_file).with_kind_of(JavascriptFile) }
      it { should respond_with(:redirect) }
    end
    
    describe "template file" do
      before do
        post :create, :account_id => @account.id, :design_id => @design.id, :template_file => { :file => File.new(RAILS_ROOT + '/spec/fixtures/test-jpg.jpg') }
      end
      
      it { should assign_to(:template_file).with_kind_of(TemplateFile) }
      it { should respond_with(:redirect) }
    end
  end

  describe "GET edit" do
    context "with a template file" do
      before do
        @template_file = Factory(:template_file, :design => @design)
        get :edit, :account_id => @account.id, :design_id => @design.id, :id => @template_file.id
      end
      
      it { should set_the_flash }
      it { should respond_with(:redirect) }
    end
    
    context "with a javascript file" do
      before do
        @template_file = Factory(:javascript_file, :design => @design)
        get :edit, :account_id => @account.id, :design_id => @design.id, :id => @template_file.id
      end
      
      it { should assign_to(:file_contents).with_kind_of(String) }
      it { should respond_with(:success) }
    end
    
    context "with a stylesheet" do
      before do
        @template_file = Factory(:stylesheet, :design => @design)
        get :edit, :account_id => @account.id, :design_id => @design.id, :id => @template_file.id
      end
      
      it { should assign_to(:file_contents).with_kind_of(String) }
      it { should respond_with(:success) }
    end
  end

  describe "PUT update" do
    before do
      @template_file = Factory(:stylesheet, :design => @design)
      put :update, :account_id => @account.id, :design_id => @design.id, :id => @template_file.id, :file_contents => "New stylesheet contents"
    end
    
    it { should set_the_flash }
    it { should respond_with(:redirect) }
  end
    
  describe "DELETE destroy" do
    before do
      @template_file = Factory(:stylesheet, :design => @design)
      delete :destroy, :account_id => @account.id, :design_id => @design.id, :id => @template_file.id
    end
    
    it { should set_the_flash }
    it { should respond_with(:redirect) }
    it "should destroy the template file" do
      lambda { TemplateFile.find(@template_file.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
