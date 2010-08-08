require 'spec_helper'

describe PublicCategoriesController do
  before do
    @account = Factory(:account)
    Account.stub!(:find).and_return(@account)
  end
  
  describe "GET to show" do
    context "with a current design" do
      before do
        @design = Factory(:design, :account => @account)
        @account.stub!(:current_design).and_return(@design)

        @template = mock('category template')
        @design.stub!(:category_template).and_return(@template)
    
        @content_drop = ContentDrop.new(@account)
        @site_drop = SiteDrop.new(@account)
        SiteDrop.stub!(:new).and_return(@site_drop)
        ContentDrop.stub!(:new).and_return(@content_drop)
      end
    
      context "viewing with current design" do
        context "for a top level page" do
          before do
            @category = Factory(:category, :account => @account)
            @category_drop = CategoryDrop.new(@category)
            CategoryDrop.stub!(:new).and_return(@category_drop)

            @template.should_receive(:render).with({ 'category' => @category_drop, 'content' => @content_drop, 'site' => @site_drop }, :registers => { :design => @design } )

            get :show, :account_id => @account.id, :id => @category.slug
          end

          it { should respond_with(:success) }
          it { should assign_to(:category).with(@category) }
          it { should assign_to(:design).with(@design) }
        end
      
        context "for a subcategory" do
          before do
            @category = Factory(:category, :parent => Factory(:category, :account => @account), :account => @account)
            @category_drop = CategoryDrop.new(@category)
            CategoryDrop.stub!(:new).and_return(@category_drop)
            @template.should_receive(:render).with({ 'category' => @category_drop, 'content' => @content_drop, 'site' => @site_drop }, :registers => { :design => @design } )

            get :show, :account_id => @account.id, :id => "#{@category.parent.slug}/#{@category.slug}"
          end

          it { should respond_with(:success) }
          it { should assign_to(:category).with(@category) }
          it { should assign_to(:design).with(@design) }
        end
      end
    
      describe "when not found" do
        before do
          @template = mock('not found template')
          @design.stub!(:not_found_template).and_return(@template)
          @template.should_receive(:render)
          get :show, :id => "no-record"
        end

        it { should respond_with(:not_found) }
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

             @category = Factory(:category, :account => @account)
             @category_drop = CategoryDrop.new(@category)
             CategoryDrop.stub!(:new).and_return(@category_drop)

             get :show, :account_id => @account.id, :id => @category.slug, :design_id => @alternate_design.id
           end

           it { should assign_to(:design).with(@alternate_design) }
        end

        context "as unqualified user" do
           before do
             @template.should_receive(:render)
             @category = Factory(:category, :account => @account)

             get :show, :account_id => @account.id, :id => @category.slug, :design_id => @alternate_design.id
           end

           it { should assign_to(:design).with(@design) }
         end
      end
    end

    context "without a current design" do
      before do
        @category = Factory(:category)
        @account.stub!(:current_design).and_return(nil)
        get :show, :account_id => @account.id, :id => @category.slug
      end

      it { should respond_with(:service_unavailable) }
    end
  end
  
end
