require 'spec_helper'

describe PublicBlogsController do  
  before do
    @account = Factory(:account)
    Account.stub!(:find).and_return(@account)
    @design = Factory(:design, :account => @account)
    @account.stub!(:current_design).and_return(@design)
    
    @content_drop = ContentDrop.new(@account)
    @site_drop = SiteDrop.new(@account)
    SiteDrop.stub!(:new).and_return(@site_drop)
    ContentDrop.stub!(:new).and_return(@content_drop)
  end
  
  describe "GET to show" do
    before do
      @blog = Factory(:blog, :status => true, :account => @account)
    end
    
    context "with a current design" do
      before do
        @template = mock('blog template')
        @design.stub!(:blog_template).and_return(@template)
      end
      
      context "viewing with current design" do
        before do
          @blog_drop = BlogDrop.new(@blog)
          BlogDrop.stub!(:new).and_return(@blog_drop)

          @template.should_receive(:render)

          get :show, :id => @blog.slug
        end
        
        it { should respond_with(:success) }
        it { should assign_to(:blog).with(@blog) }
        it { should assign_to(:design).with(@design) }
      end
      
      describe "viewing with alternate design" do
        before do
          @alternate_design = Factory(:design, :account => @account)
        end
          
        context "as qualified user" do
           before do
             @current_user = Factory(:user)
             @current_user.promote_to_admin
             controller.stub!(:current_user).and_return(@current_user)
             
             get :show, :id => @blog.slug, :design_id => @alternate_design.id
           end
           
           it { should assign_to(:design).with(@alternate_design) }
        end
         
        context "as unqualified user" do
           before do
             @template.should_receive(:render)
             get :show, :id => @blog.slug, :design_id => @alternate_design.id
           end
           
           it { should assign_to(:design).with(@design) }
         end
      end
    end
    
    describe "when not found" do
      before do
        @template = mock('not found template')
        @design.stub!(:not_found_template).and_return(@template)
        @template.should_receive(:render)
        get :show, :id => "no-blog-is-here"
      end

      it { should respond_with(:not_found) }
      it { should assign_to(:design).with(@design) }
    end
    
    context "without a current design" do
      before do
        @account.stub!(:current_design).and_return(nil)
        get :show, :id => @blog.slug
      end
    
      it { should respond_with(:service_unavailable) }
    end
  end
  
  describe "GET to index" do
    before do
      @blogs = (1..3).collect{ Factory(:blog, :status => true, :account => @account) }
    end
    
    context "with a current design" do
      before do
        @template = mock('blog index template')
        @design.stub!(:blog_index_template).and_return(@template)
      end
      
      context "viewing with current design" do
        before do
          @template.should_receive(:render)

          get :index
        end
        
        it { should respond_with(:success) }
        it { should assign_to(:blogs).with(@blogs) }
        it { should assign_to(:design).with(@design) }
      end
      
      describe "viewing with alternate design" do
        before do
          @alternate_design = Factory(:design, :account => @account)
        end
          
        context "as qualified user" do
           before do
             @current_user = Factory(:user)
             @current_user.promote_to_admin
             controller.stub!(:current_user).and_return(@current_user)
             
             get :index, :design_id => @alternate_design.id
           end
           
           it { should assign_to(:design).with(@alternate_design) }
        end
         
        context "as unqualified user" do
           before do
             @template.should_receive(:render)
             get :index, :design_id => @alternate_design.id
           end
           
           it { should assign_to(:design).with(@design) }
         end
      end
    end
    
    context "without a current design" do
      before do
        @account.stub!(:current_design).and_return(nil)
        get :index
      end
    
      it { should respond_with(:service_unavailable) }
    end
  end

end
