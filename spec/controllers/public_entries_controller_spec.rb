require 'spec_helper'

describe PublicEntriesController do
  describe "GET to show" do
    before do
      @account = Factory(:account)
      Account.stub!(:find).and_return(@account)
    end
    
    context "with a current design" do
        before do
          @design = Factory(:design, :account => @account)
          @account.stub!(:current_design).and_return(@design)

          @template = mock('entry template')
          @design.stub!(:entry_template).and_return(@template)

          @content_drop = ContentDrop.new(@account)
          @site_drop = SiteDrop.new(@account)
          SiteDrop.stub!(:new).and_return(@site_drop)
          ContentDrop.stub!(:new).and_return(@content_drop)
        end

        context "viewing with current design" do
          context "for a published entry" do
            before do
              @entry = Factory(:published_entry, :account => @account)
              @entry_drop = EntryDrop.new(@entry)
              EntryDrop.stub!(:new).and_return(@entry_drop)

              @template.should_receive(:render).with({ 'entry' => @entry_drop, 'content' => @content_drop, 'site' => @site_drop }, :registers => { :design => @design } )
              get :show, :account_id => @account.id, :blog_slug => @entry.blog.slug, :id => @entry.id
            end

            it { should respond_with(:success) }
            it { should assign_to(:entry).with(@entry) }
            it { should assign_to(:design).with(@design) }
          end
        end
        
        describe "unpublished entry preview" do
          before do
            @entry = Factory(:entry, :account => @account)
          end

          context "for a user with read access" do
            before do
              @current_user = Factory(:user)
              @current_user.promote_to_admin
              controller.stub!(:current_user).and_return(@current_user)

              @entry_drop = EntryDrop.new(@entry)
              EntryDrop.stub!(:new).and_return(@entry_drop)          
              @template.should_receive(:render).with({ 'entry' => @entry_drop, 'content' => @content_drop, 'site' => @site_drop }, :registers => { :design => @design } )

              get :show, :account_id => @account.id, :blog_slug => @entry.blog.slug, :id => @entry.id
            end

            it { should respond_with(:success) }
            it { should assign_to(:entry).with(@entry) }
            it { should assign_to(:design).with(@design) }
          end

          context "for a non-user" do
            it "should raise a not found error" do
              lambda{ get :show, :account_id => @account.id, :blog_slug => @entry.blog.slug, :id => @entry.id }.should raise_error(ActiveRecord::RecordNotFound)
            end
          end
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

               @entry = Factory(:published_entry, :account => @account)
               @entry_drop = EntryDrop.new(@entry)
               EntryDrop.stub!(:new).and_return(@entry_drop)

               get :show, :account_id => @account.id, :blog_slug => @entry.blog.slug, :id => @entry.id, :design_id => @alternate_design.id
             end

             it { should assign_to(:design).with(@alternate_design) }
          end

          context "as unqualified user" do
             before do
               @template.should_receive(:render)
               @entry = Factory(:published_entry, :account => @account)

               get :show, :account_id => @account.id, :blog_slug => @entry.blog.slug, :id => @entry.id, :design_id => @alternate_design.id
             end

             it { should assign_to(:design).with(@design) }
           end
        end
      end
      
    context "without a current design" do
      before do
        @entry = Factory(:published_entry, :account => @account)
        get :show, :account_id => @account.id, :blog_slug => @entry.blog.slug, :id => @entry.id
      end
    
      it { should respond_with(:service_unavailable) }
    end
  end
  
end
