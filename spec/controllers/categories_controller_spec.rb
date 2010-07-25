require 'spec_helper'

describe CategoriesController do
  before do
    @account = Factory(:account)
    controller.stub!(:current_subdomain).and_return(@account.name)
    controller.stub!(:login_required).and_return(true)
  end
  
  describe "POST to create with XHR request" do
    context "with valid category parameters" do
      before do
        xhr :post, :create, :category => { :name => "Health" }
      end
      
      it { should respond_with(:success) }
      it { should respond_with_content_type(:js) }
      it "should create category" do
        should assign_to(:category).with_kind_of(Category)
        assigns(:category).should_not be_new_record
      end
    end
    
    context "with invalid parameters" do
      before do
        xhr :post, :create, :category => { :name => "" }
      end    
      it { should respond_with(:success) }
      it { should respond_with_content_type(:js) }
      it "should not create category" do
        should assign_to(:category).with_kind_of(Category)
        assigns(:category).should be_new_record
      end
    end
  end
  
  describe "GET to edit with XHR request" do
    before do
      @category = Factory(:category, :name => "one thing", :account => @account)
      xhr :get, :edit, :id => @category.id
    end
    
    it { should respond_with(:success) }
    it { should respond_with_content_type(:js) }
    it { should assign_to(:category).with(@category) }
  end
  
  describe "PUT to update with XHR request" do
    before do
      @category = Factory(:category, :name => "one thing", :account => @account)
      xhr :put, :update, :id => @category.id, :category => { :name => "and another thing" }
    end
    
    it { should respond_with(:success) }
    it { should respond_with_content_type(:js) }
    it { should set_the_flash.to('Category updated') }
    it "should update category" do
      assign_to(:category).with(@category)
      assigns(:category).name.should == "and another thing"
    end
  end
  
  describe "PUT to deactivate" do
    before do
      @category = Factory(:category, :account => @account, :name => "one thing")
      xhr :put, :deactivate, :id => @category.id
    end
    
    it { should respond_with(:success) }
    it { should respond_with_content_type(:js) }
    it "should deactivate category" do
      should assign_to(:category).with(@category)
      assigns(:category).should_not be_active
    end
  end
  
  describe "PUT to reactivate" do
    before do
      @category = Factory(:category, :account => @account, :active => false)
      xhr :put, :reactivate, :id => @category.id
    end
    
    it { should respond_with(:success) }
    it { should respond_with_content_type(:js) }
    it "should reactivate category" do
      should assign_to(:category).with(@category)
      assigns(:category).should be_active
    end
  end
  
  describe "DELETE to destroy" do
    before do
      @category = Factory(:category, :name => "one thing", :account => @account)
      xhr :delete, :destroy, :id => @category.id
    end
    
    it { should respond_with(:success) }
    it { should respond_with_content_type(:js) }
    it "should delete the category" do
      should assign_to(:category).with(@category)
      lambda { Category.find(@category.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
