require File.dirname(__FILE__) + "/../spec_helper"
require File.dirname(__FILE__) + "/../content_spec_helper"

describe ContentController, "create a content model" do

  reset_domain_tables :end_users, :roles, :user_roles, :access_tokens, :end_user_tokens, :site_modules

  include ContentSpecHelper

 integrate_views
 
 before(:all) do
    # Need to clean out the content models and create a new content model
    # But don't want to do this before each one
    create_content_model_with_all_fields
  end

  describe "Should be able to manipulate content" do 
    
    before(:each) do
      mock_editor
    end
    
    describe "Should be able to list, add and edit entries" do 
      
      # Kill the ContentModel table
      reset_domain_tables :end_users, :cms_controller_spec_tests
      
      it "should handle custom content models table" do 
        get :custom
      end  
      
      it "should be able to display the index page" do
        get :index
      end
      
      it "should be able to display a custom content model table" do
        @cm.content_model.create(:string_field => 'Tester',:date_field => "6/13/2009")
        @cm.content_model.create(:string_field => 'Tester2',:date_field => "6/13/2009")

        get :view, :path => [ @cm.id ]
      end
      
      it "should be able to display a custom content model table with tags" do
	@cm.update_attributes(:show_tags => true)
        @cm.content_model.create(:string_field => 'Tester',:date_field => "6/13/2009")
        @cm.content_model.create(:string_field => 'Tester2',:date_field => "6/13/2009")
        
        get :view, :path => [ @cm.id ]

	@cm.update_attributes(:show_tags => false)
      end
      
      it "should be able to display the view of an item" do
        @entry = @cm.content_model.create(:string_field => '<h1>Test Escaped Field</h1>',:date_field => "6/13/2009", :html_field => '<h1>Html Field</h1>')

        get :entry, :path => [ @cm.id, @entry.id ]

        response.should render_template('content/entry')
        # Make sure escaped field shown correctly
        
        
        response.body.should include("&lt;h1&gt;Test Escaped Field&lt;/h1&gt;")
        response.body.should include('<h1>Html Field</h1>')
      end
      

      it "should be able to display a creation form" do
        get :edit_entry, :path => [ @cm.id ]
        
        response.should render_template('content/edit_entry')  
      end
      
      it "should be able to display new model page" do
        get :new
        
        response.should render_template('content/new')  
      end

      it "should be able to create a new model" do

	assert_difference 'ContentModel.count', 1 do
	  MigrationHandlerWorker.should_receive(:async_do_work).and_return('new_worker')
	  Workling.return.should_receive(:get).with('new_worker').and_return(true)

	  post :new, :content_model => {:name => 'new test model'}
        end

	new_cm = ContentModel.find(:last)
	new_cm.name.should == 'new test model'
        response.should redirect_to(:action => :edit, :path => new_cm.id, :created => 1)
      end

      it "should be able to display a add tags form" do
	@cm.update_attributes(:show_tags => true)

        get :add_tags_form, :path => [ @cm.id ]
        
        response.should render_template('content/add_tags_form')  

	@cm.update_attributes(:show_tags => false)
      end
      
      it "should be able to display a remove tags form" do
	@cm.update_attributes(:show_tags => true)
        @md1 = @cm.content_model.create(:string_field => 'Tester',:date_field => "6/13/2009")
        @md2 = @cm.content_model.create(:string_field => 'Tester2',:date_field => "6/13/2009")
	@md1.add_tags('new_tag')

        get :remove_tags_form, :path => [ @cm.id ], :entry_ids => [@md1.id.to_s]
        
        response.should render_template('content/remove_tags_form')  

	@cm.update_attributes(:show_tags => false)
      end
      
      it "shouldn't create an item if the required string field isn't set" do
        cls = @cm.content_model
        @entry = cls.new 
        
        # cls is unnamed so we need to chain our should_receives together
        ContentModel.should_receive(:find).at_least(:once).and_return(@cm)
        @cm.should_receive(:content_model).at_least(:once).and_return(cls)
        cls.should_receive(:new).and_return(@entry)
        
        put :edit_entry, :path => [ @cm.id], :entry => { :html_field => 'HTML FIELD!' }
        
        
        response.should render_template('content/edit_entry')
      end
      
      it "should create an item if the required string field is set" do
        cls = @cm.content_model
        @entry = cls.new 
        
        # cls is unnamed so we need to chain our should_receives together
        ContentModel.should_receive(:find).at_least(:once).and_return(@cm)
        @cm.should_receive(:content_model).at_least(:once).and_return(cls)
        cls.should_receive(:new).and_return(@entry)
        
        put :edit_entry, :path => [ @cm.id], :entry => { :string_field => 'Testerama', :html_field => 'HTML FIELD!' }
        
        response.should render_template('content/edit_entry')
      end  

      it "should be view the edit form of an existing item " do
        @entry = @cm.content_model.create(:string_field => '<h1>Test Escaped Field</h1>',:date_field => "6/13/2009", :html_field => '<h1>Html Field</h1>')

        get :edit_entry, :path => [ @cm.id, @entry.id ]
        
        response.should render_template('content/edit_entry')  
      end

      it "should be able modify an existing item" do
        @entry = @cm.content_model.create(:string_field => '<h1>Test Escaped Field</h1>',:date_field => "6/13/2009", :html_field => '<h1>Html Field</h1>')

        post :edit_entry, :path => [ @cm.id, @entry.id ], :entry => { :string_field => 'Test Field' }, :commit => true

        @entry.reload
	@entry.string_field.should == 'Test Field'

        response.should redirect_to(:action => 'view', :path => [ @cm.id ] )  
      end

      it "should not be able modify an existing item if commit is not set" do
        @entry = @cm.content_model.create(:string_field => '<h1>Test Escaped Field</h1>',:date_field => "6/13/2009", :html_field => '<h1>Html Field</h1>')

        post :edit_entry, :path => [ @cm.id, @entry.id ], :entry => { :string_field => 'Test Field' }

        @entry.reload
	@entry.string_field.should_not == 'Test Field'

        response.should redirect_to(:action => 'view', :path => [ @cm.id ] )  
      end

      it "should be able to add a new field" do
	post :new_field, :add_field => {:name => 'new test field', :field_type => 'string'}
	response.should render_template('content/edit_field')
      end

      it "should warn when adding a field with missing data" do
	post :new_field, :add_field => {:name => '', :field_type => 'string'}
	response.body.should include('alert')
      end

      it "should be able to update a new model" do
	field = @cm.content_model_fields.find(:first)

	MigrationHandlerWorker.should_receive(:async_do_work).and_return('new_worker')
	Workling.return.should_receive(:get).with('new_worker').and_return(true)

	post :update_model, :path => [@cm.id], :model_fields => [field.id.to_s], :field => {field.id.to_s => field.attributes}

        response.should render_template('content/update_model')
      end

      it "should be able to destroy a content model" do
	MigrationHandlerWorker.should_receive(:async_do_work).and_return('new_worker')
	Workling.return.should_receive(:get).with('new_worker').and_return(true)

	controller.session[:destroy_content_hash] = 'delete'
	post :destroy, :path => [@cm.id], :destroy => 'delete'

        response.should redirect_to(:action => 'index')
      end
    end

    describe "should support active table" do
      reset_domain_tables :end_users, :cms_controller_spec_tests, :content_tag_tags, :content_tags

      before(:each) do
	@cm.update_attributes(:show_tags => true)
        @md1 = @cm.content_model.create(:string_field => 'Tester',:date_field => "6/13/2009")
        @md2 = @cm.content_model.create(:string_field => 'Tester2',:date_field => "6/13/2009")

	controller.class.send('attr_accessor', :content_model)
	controller.class.send('attr_reader', :generated_active_table_columns)
	controller.send('content_model=', @cm)
	@active_table_output = controller.send('generate_active_table')
	controller.should_receive("#{@cm.table_name}_columns".to_sym).any_number_of_times.and_return(controller.generated_active_table_columns)
      end

      after(:each) do
	@cm.update_attributes(:show_tags => false)
      end

      it "should support searching active table" do
	# Test all the permutations of an active table
	controller.should handle_active_table(@cm.table_name) do |args|
	  post 'active_table', {:path => [@cm.id]}.merge(args)
	end
      end

      it "should be able to delete content model data" do
	@md1.id.should_not be_nil

	assert_difference "@cm.content_model.count", -1 do
	  post 'active_table', :path => [@cm.id], :table_action => 'delete', :entry => {@md1.id.to_s => true}
	end
      end

      it "should be able to copy content model data" do
	@md1.id.should_not be_nil

	assert_difference "@cm.content_model.count", 1 do
	  post 'active_table', :path => [@cm.id], :table_action => 'copy', :entry => {@md1.id.to_s => true}
	end
      end

      it "should be able to add tags to content model data" do
	@md1.id.should_not be_nil

	assert_difference "ContentTagTag.count", 1 do
	  post 'active_table', :path => [@cm.id], :table_action => 'add_tags', :entry => {@md1.id.to_s => true}, :added_tags => 'new_tag'
	end

	tag = ContentTag.find_by_name_and_content_type('new_tag', @md1.class.to_s)
	tag.should_not be_nil
	tag_tags = ContentTagTag.find_by_content_tag_id_and_content_type_and_content_id(tag.id, @md1.class.to_s, @md1.id)
	tag_tags.should_not be_nil
      end

      it "should be able to remove tags from content model data" do
	@md1.id.should_not be_nil
	@md1.add_tags('new_tag')

	tag = ContentTag.find_by_name_and_content_type('new_tag', @md1.class.to_s)
	tag.should_not be_nil
	tag_tags = ContentTagTag.find_by_content_tag_id_and_content_type_and_content_id(tag.id, @md1.class.to_s, @md1.id)
	tag_tags.should_not be_nil

	assert_difference "ContentTagTag.count", -1 do
	  post 'active_table', :path => [@cm.id], :table_action => 'remove_tags', :entry => {@md1.id.to_s => true}, :removed_tags => 'new_tag'
	end

	tag_tags = ContentTagTag.find_by_content_tag_id_and_content_type_and_content_id(tag.id, @md1.class.to_s, @md1.id)
	tag_tags.should be_nil
      end
    end

    describe "should be able to edit fields" do
      
      it "should be able to show the edit fields page" do 
        get :edit, :path => [ @cm.id ]
        
        response.should render_template('content/edit')
      end
      
    end

    describe "should be able to configure content model" do
      it "should display configure page" do
	get :configure, :path => [ @cm.id ]
        
        response.should render_template('content/configure')
      end

      it "should edit a content model" do
	show = {@cm.content_model_fields.first.id.to_s => true}
	post :configure, :path => [ @cm.id ], :content => {:identifier_name => 'Test Identifier'}, :show => show
        @cm.reload
	@cm.identifier_name.should == 'Test Identifier'
        response.should redirect_to(:action => :view, :path => @cm.id)
      end
    end

  end

  describe "Should be able to control access" do

    it "should kick user out if they have no permissions" do
      mock_editor('test@webiva.com',[]) # no permissions

      get :view, :path => [ @cm.id ]

      response.should redirect_to(:controller => '/manage/access', :action => 'denied')
    end


    it "should let the user in if they are allowed" do
      mock_editor('test@webiva.com',[ :editor_content ])
      # content permission

      get :view, :path => [ @cm.id ]

      response.should render_template('content/view')
    end


    it "shouldn't let users in if the content model is protected" do
      @cm.update_attributes(:view_access_control => true)

      mock_editor('test@webiva.com',[ :editor_content ])
      # content permission

      get :view, :path => [ @cm.id ]

      response.should redirect_to(:controller => '/manage/access', :action => 'denied')
    end


     it "should let users in if the content model is protected and we have an access token" do
      @cm.update_attributes(:view_access_control => true)
      tkn = AccessToken.create(:editor => true,:token_name => 'Tester')

      tkn.has_role('view_access_control',@cm)

      mock_editor('test@webiva.com',[ :editor_content ])
      # content permission

      @myself.add_token!(tkn)
      
      get :view, :path => [ @cm.id ]

      response.should render_template('content/view')
    end

    it "should check to see if user can see content" do
      mock_editor('test@webiva.com',[:editor_content, :editor_content_configure]) # no permissions

      @myself.should_receive(:has_role?).any_number_of_times.with('editor_content').and_return(true)
      @myself.should_receive(:has_role?).any_number_of_times.with(:editor_content).and_return(true)
      @myself.should_receive(:has_role?).any_number_of_times.with('editor_content_configure').and_return(true)
      @myself.should_receive(:has_role?).any_number_of_times.with(:editor_content_configure).and_return(true)
      @myself.should_receive(:has_role?).exactly(0).with(:view_access_control, anything()).and_return(true)
      get :index
    end

    it "should check to see if user can see content with view acces controls" do
      mock_editor('test@webiva.com',[:editor_content]) # no permissions

      @cm.update_attributes(:view_access_control => true)

      @myself.should_receive(:has_role?).any_number_of_times.with('editor_content').and_return(true)
      @myself.should_receive(:has_role?).any_number_of_times.with(:editor_content).and_return(true)
      @myself.should_receive(:has_role?).any_number_of_times.with('editor_content_configure').and_return(false)
      @myself.should_receive(:has_role?).any_number_of_times.with(:editor_content_configure).and_return(false)
      @myself.should_receive(:has_role?).any_number_of_times.with(:view_access_control, anything()).and_return(true)
      get :index

      @cm.update_attributes(:view_access_control => false)
    end

    it "should check to see if user can see content without view acces controls" do
      mock_editor('test@webiva.com',[:editor_content]) # no permissions

      @myself.should_receive(:has_role?).any_number_of_times.with('editor_content').and_return(true)
      @myself.should_receive(:has_role?).any_number_of_times.with(:editor_content).and_return(true)
      @myself.should_receive(:has_role?).any_number_of_times.with('editor_content_configure').and_return(false)
      @myself.should_receive(:has_role?).any_number_of_times.with(:editor_content_configure).and_return(false)
      @myself.should_receive(:has_role?).exactly(0).with(:view_access_control, anything())
      get :index
    end

    it "should check to see if user can edit content" do
      mock_editor('test@webiva.com',[:editor_content]) # no permissions

      @cm.update_attributes(:edit_access_control => true)

      @myself.should_receive(:has_role?).any_number_of_times.with(:editor_content_configure).and_return(false)
      @myself.should_receive(:has_role?).any_number_of_times.with('edit_access_control', anything()).and_return(true)
      controller.should_receive(:deny_access!).exactly(0)
      get :edit_entry, :path => [@cm.id]

      @cm.update_attributes(:edit_access_control => false)
    end

    it "should be denied if they can not edit content" do
      mock_editor('test@webiva.com',[:editor_content]) # no permissions

      @cm.update_attributes(:edit_access_control => true)

      @myself.should_receive(:has_role?).any_number_of_times.with(:editor_content_configure).and_return(false)
      @myself.should_receive(:has_role?).any_number_of_times.with('edit_access_control', anything()).and_return(false)
      controller.should_receive(:deny_access!).once
      get :edit_entry, :path => [@cm.id]

      @cm.update_attributes(:edit_access_control => false)
    end

  end
 
end

