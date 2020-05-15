require 'net/http'

class DocumentsController < ApplicationController
  include DocumentsHelper
  layout 'view'

  before_action :get_organization, only: [:course_select, :course_link, :template]
  before_action :redirect_to_sub_org, only:[:index,:new,:show,:edit,:course, :course_list]
  before_action :x_frame_allow_all, only:[:new,:show,:edit,:course]
  before_action :lms_connection_information, :only => [:update, :edit, :course, :course_list]
  before_action :lookup_document, :only => [:edit, :update]
  before_action :init_view_folder, :only => [:new, :edit, :update, :show, :course]
  before_action :set_paper_trail_whodunnit
  before_action :validate_can_use_course_edit_token, only: [:course_select, :new, :course_link, :template] 

  def index
    redirect_to new_document_path(org_path: params[:org_path])
  end


  def new
    @document = Document.new
    verify_org

    @document.name = params[:name] if params[:name]
    link_document_course(@document)
    @document.save!
    
    redirect_to edit_document_or_lms_course_path(
      condition: params[:lms_course_id] && @document.lms_course_id,
      lms_course_id: @document.lms_course_id, 
      id: @document.edit_id,
      batch_token: params[:batch_token],
      org_path: params[:org_path]
    )
  end

  def show
    document = Document.find_by_edit_id(params[:id])
    document_template = Document.find_by_template_id(params[:id])
    @document = Document.find_by_view_id(params[:id])

    if params[:version].to_i > 0 && @document
      @document = @document.versions[params[:version].to_i].reify
    end

    if document_template != nil
      redirect_to template_document_path(
        relink: true,
        lms_course_id: params[:lms_course_id],
        id: document_template.template_id, 
        org_path: params[:org_path],
        name: params[:name], 
        batch_token: params[:batch_token])
      return
    end
    raise ActionController::RoutingError.new('Not Found') unless document || @document
    if document
      redirect_to edit_document_path(:id => document.edit_id, :org_path => params[:org_path], :batch_token => params[:batch_token])
      return
    end

    @calendar_only = params[:calendar_only] ? true : false
    if @document.organization.disable_document_view
      return render :file => "public/404.html", :status => :not_found, :layout => false
    end
    @action = 'show'

    respond_to do |format|
      format.html {
        render :layout => 'view', :template => '/documents/content'
      }
      format.pdf{
        html = render_to_string :layout => 'view', :template => '/documents/content.html.erb'
        content = Rails.env.development? ? WickedPdf.new.pdf_from_string(html.force_encoding("UTF-8")) : html
        render :text => content, :layout => false
      }
    end
  end

  def edit
    if check_lock @organization, params[:batch_token]
      if params[:version].to_i > 0
        @document_version = params[:version].to_i
        @document = @document.versions[@document_version].reify
      else
        @document_version = @document.versions.count
      end
      verify_org

      @view_url = view_url
      @template_url = template_url(@document)

      @can_use_edit_token = can_use_edit_token(@document.lms_course_id)
      if @organization.root_org_setting("enable_workflows") && @document.assigned_to?(current_user) && @document.workflow_step_id
        render :layout => 'edit', :template => '/documents/content'
      elsif @organization.root_org_setting("enable_workflows") && has_role("supervisor") && @document.workflow_step&.step_type == "end_step"
        render :layout => 'edit', :template => '/documents/content'
      elsif !@organization.root_org_setting("enable_workflows") || !@document.workflow_step_id || !@document.user_id
        render :layout => 'edit', :template => '/documents/content'
      elsif current_user != nil
        flash[:notice] = "you are not authorized to edit that document"
        redirect_to admin_path(org_path: params[:org_path])
      else
        flash[:notice] = "you are not authorized to edit that document please login to continue"
        redirect_to admin_path(org_path: params[:org_path])
      end
    else
      render :layout => 'dialog', :template => '/documents/republishing'
    end
  end

  def course_link
    # course_link populates a documents empty course id
    get_lms_course @organization.setting('lms_authentication_source')
    document = @organization.documents.find_by view_id: params[:id]

    if link_document_course(document)
      redirect_to edit_document_or_lms_course_path(
        condition: !params[:course],
        id: document.edit_id, 
        lms_course_id: params[:lms_course_id]
      )
    else
      return redirect_to lms_course_select_path org_path: params[:org_path], lms_course_id: params[:lms_course_id]
    end
  end

  def course_select page=params[:page], per=15
    # select_course gives the user a dialog for what to do with a course that has no document yet
    allow_existing_salsas_for_new_courses = @organization.root_org_setting("allow_existing_salsas_for_new_courses")
    get_lms_course @organization.setting('lms_authentication_source')
    @course_id = params[:lms_course_id]
    @existing_document = Document.find_by view_id: params[:document_token], organization_id: @organization.root.self_and_descendants if params[:document_token]
    @existing_document ||= Document.find_by lms_course_id: @course_id, organization_id: @organization.root.self_and_descendants

    user = current_user
    if user
      @documents = Document.where(
        "user_id = :user_id and organization_id = :organization_id and documents.updated_at <> documents.created_at", 
        {user_id: user.id, organization_id: @organization}).order(updated_at: :desc, created_at: :desc).page(page).per(per)
    end

    if !existing_document? && !allow_existing_salsas_for_new_courses && !params[:document_token] && !params[:canvas]
      redirect_to new_document_path(
        lms_course_id: @course_id, 
        org_path: params[:org_path], 
        name: get_course_name, 
        relink: params[:relink])
    else
      # if existing_document?
      #   flash[:error] = "A SALSA linked to course '#{@course_id}' already exists. Please contact your Salsa Administrator to resolve this issue."
      # end
      
      render layout: 'relink', template: '/documents/course_select', notice: "hi", locals: {
        has_existing_document: @existing_document && !@existing_document&.same_record_as?(@document),
        allow_existing_salsas_for_new_courses: allow_existing_salsas_for_new_courses}

    end
  end

  def course
    # if canvas flag is set in URL, don't try relinking again
    unless params[:canvas]
      # if clicked the create new document link on relink page, clear out the session relink value
      if params[:create_new]
        session['relink_'+params[:lms_course_id]] = nil
      # if we got here from a relink action, keep track of the document token in case the user is not logged in yet
      elsif params[:document_token] && params[:lms_course_id]
        session['relink_'+params[:lms_course_id]] = params[:document_token]
      end
    end
    
    lms_authentication_source = @organization.setting('lms_authentication_source')
    get_lms_course lms_authentication_source

    if @lms_course
      # see if there is a organization matched for course
      if @organization.root_org_setting('redirect_by_lms_account_id') && @lms_course['account_id'] && @organization.lms_account_id.to_s != @lms_course['account_id'].to_s 
        org_by_lms_account = get_org_by_lms_account_id
        if !org_by_lms_account.blank?
          return redirect_to lms_account_course_document_path org_by_lms_account
        end
      end
      
      @document = Document.find_by lms_course_id: params[:lms_course_id], organization: @organization.self_and_descendants

      # if no document_token is in the params, but there is a relink value matching the current course, use that, then clear it
      if session['relink_'+params[:lms_course_id]] && !params[:document_token]
        params[:document_token] = session['relink_'+params[:lms_course_id]]
      end

      if @document.blank? || !token_matches? 
        session.delete('relink_'+params[:lms_course_id]) if session['relink_'+params[:lms_course_id]]
        return redirect_to lms_course_select_path(org_path: params[:org_path], lms_course_id: params[:lms_course_id], document_token: params[:document_token], name: @lms_course['name'])
      end

      @document = @document.versions[params[:version].to_i].reify if params[:version]

      @view_pdf_url = view_pdf_url
      @view_url = view_url
      @template_url = template_url(@document)

      # backwards compatibility alias
      @syllabus = @document

      return render :layout => 'edit', :template => '/documents/content'
    else
      session[:redirect_course_id] = params[:lms_course_id]

      if params[:document_token]
        redirect_to '/oauth2/login', lms_course_id: params[:lms_course_id], document_token: params[:document_token], org_path: params[:org_path]
      else
        redirect_to '/oauth2/login', lms_course_id: params[:lms_course_id], org_path: params[:org_path]
      end
    end

  end

  def course_list
    raise ActionController::RoutingError.new('Not Found') unless @lms_user

    verify_org

    @page = 1
    if params[:page]
      @page = params[:page].to_i if params[:page]
    end

    @lms_courses = @lms_client.get("/api/v1/courses", per_page: 20, page: @page) if @lms_client.token

    render :layout => 'organizations', :template => '/documents/from_lms'
  end

  def template
    # duplicate the template and save it as a new document.
    template = Document.find_by template_id: params[:id], organization_id: @organization.root.self_and_descendants
    unless template
      return render :file => "public/404.html", :status => :not_found, :layout => false
    end
    @document = template
    verify_org
    document = template.dup
    document.reset_ids
    period = Period.find_by(is_default: true, organization: @organization.self_and_ancestors )
    document.period = period if period
    document.name = params[:name] if params[:name]
    link_document_course(document)
    document.save!
    redirect_to edit_document_or_lms_course_path(
      condition: params[:lms_course_id] && document.lms_course_id,
      id: document.edit_id,
      lms_course_id: document.lms_course_id,
      org_path: params[:org_path], 
      batch_token: params[:batch_token]
    )
  end

  def update
    canvas_course_id = params[:canvas_course_id]
    document_version = params[:document_version]
    meta_data_from_doc = params[:meta_data_from_doc]
    saved = false
    republishing = true
    @organization = @document.organization if !@document.organization.blank?
    verify_org
    user = current_user if current_user
    assigned_to_user = @document.assigned_to? user
    
    lms_authentication_source = @organization.root_org_setting('lms_authentication_source')
    has_canvas_publish = lms_authentication_source.include?('instructure.com') if lms_authentication_source

    if (check_lock @organization, params[:batch_token]) && can_use_edit_token(@document.lms_course_id)
      republishing = false;

      if meta_data_from_doc && @organization.root_org_setting("lms_authentication_id") && @organization.root_org_setting("track_meta_info_from_document")
        create_meta_data_from_document(meta_data_from_doc)
        meta_data_from_doc_saved = true
      elsif has_canvas_publish && canvas_course_id && !@organization.skip_lms_publish
        # publishing to canvas should not save in the Document model, the canvas version has been modified
        saved = update_course_document(canvas_course_id, request.raw_post, @organization[:lms_info_slug], @lms_client, @document) if params[:canvas] && canvas_course_id
      elsif !meta_data_from_doc
        if(params[:canvas_relink_course_id])
          #find old document in this org with this id, set to null
          old_document = Document.find_by lms_course_id: params[:canvas_relink_course_id], organization: @organization
          old_document.update(lms_published_at: nil, lms_course_id: nil)

          #set this document's canvas_course_id
          @document.lms_course_id = params[:canvas_relink_course_id]
        end
        if document_version && @document.versions.count == document_version.to_i
          @document.payload = request.raw_post
          @document.payload = nil if @document.payload == ''
          @document.user_id ||= user&.id

          if !@organization.root_org_setting("enable_workflows") || !@document.workflow_step_id || !@document.user_id
            @document.save!
            saved = true;
          elsif @organization.root_org_setting("enable_workflows") && user && @document.workflow_step_id && assigned_to_user
            @document.save!
            saved = true;
          end
        end
      end
      if params[:publish] == "true" && @organization.root_org_setting("enable_workflows") && user && saved
        if @document.workflow_step_id && @document.assigned_to?(user)
          @document.paper_trail_event = 'publish'
          @document.published_at = DateTime.now
          @document.save!
          
          # Log the current action, then save, then send any emails
          workflow_log = WorkflowLog.create(user: current_user, step_id: @document.workflow_step.id, document: @document, role: @document.workflow_step.component.role)
          @document.update(workflow_step_id: @document.workflow_step.next_workflow_step_id) if @document.workflow_step&.next_workflow_step_id && (@document.workflow_step.component.role != "approver"|| @document.signed_by_all_approvers)
          WorkflowMailer.step_email(@document, component_allowed_liquid_variables(@document.workflow_step, user,@organization, @document)).deliver_later
        end
        flash[:notice] = 'The workflow document step has been completed'
        flash.keep(:notice)
        return render :js => "window.location = '#{admin_path}'"
      end
    end
    respond_to do |format|
      msg = { status: "error", message: "error" }

      if can_use_edit_token(@document.lms_course_id) != true
        msg[:message] = "You do not have permission to save this document"
      else
        msg[:version] = @document.versions.count
        
        if republishing
          msg[:message] = "Documents for this organization are currently being republished. Please copy your changes and try again later."
        elsif @organization.root_org_setting("track_meta_info_from_document") == false && meta_data_from_doc != nil
          msg[:message] = "Tried to save document meta when document meta not enabled for this organization"
        elsif !saved && !meta_data_from_doc_saved
          msg[:message] = "This is not a current version of this document! Please copy your changes and refresh the page to get the current version."
        else
          msg[:status] = "ok"
          msg[:message] = "Success!"
        end
      end
      format.json  {
        view_url = document_url(@document.view_id, :only_path => false)
        render :json => msg
      }
    end
  end

  protected

  def validate_can_use_course_edit_token lms_course_id = params[:lms_course_id]
    unless can_use_edit_token(lms_course_id)
      return redirect_to root_path(org_path: params[:org_path]), :flash => { :error => "You are not authorized to create a document" }
    end
  end
  
  def token_matches?
    return params[:document_token].blank? || @document&.view_id == params[:document_token]
  end

  def get_lms_course lms_authentication_source
    if ENV['RAILS_ENV'] == "test"
      @lms_course = fake_lms_course
    elsif lms_authentication_source == 'LTI'
      if is_lti_authenticated_course?(params[:lms_course_id])
        lti_course_id = session[:lti_info]['course_id']
        @lms_course = {'name'=>lti_course_id,'id'=>lti_course_id}.merge(session[:lti_info])
      else
        raise ActionController::RoutingError.new('Not Authorized')
      end
    elsif lms_authentication_source != ''
      begin
        if @lms_client && @lms_client.token
          @lms_course = @lms_client.get("/api/v1/courses/#{params[:lms_course_id]}", { include: 'syllabus_body' })
        end
      rescue
        # if a designer of the org, allow them to pass...
        if has_role('designer')
          @lms_course = fake_lms_course
        else
          raise ActionController::RoutingError.new('Not Authorized')
        end
      end
    end
  end

  def fake_lms_course
    return { 
      name: "Generated by Course Designer - #{params[:lms_course_id]}",
      id: params[:lms_course_id]
    }
  end

  def create_meta_data_from_document meta_data_from_doc
    lms_authentication_id = @organization.root_org_setting("lms_authentication_id")
    lms_course_id = @document.lms_course_id
    hash = {
      root_organization_id: @organization.root.id,
      lms_course_id: lms_course_id,
      lms_organization_id: lms_authentication_id
    }
    meta_data_from_doc.each do |c,md|
      count = c.to_i + 1
      k = "salsa_#{md['key']}_#{count}"
      dm = DocumentMeta.find_or_initialize_by(key: k, document_id: @document.id)
      h = hash.merge(value: md[:value].to_s)
      h[:lms_course_id] = md['lms_course_id'] if md['lms_course_id']
      h[:lms_course_id] = md[:lms_course_id] if md[:lms_course_id].present?
      dm.update h
    end
  end

  def can_use_edit_token(lms_course_id = nil)
    is_authorized = is_saml_authenticated_user? && (has_canvas_access_token? || session.key?('lti_info')) && lms_course_id

    user = current_user
    workflow_authorized = @organization.root_org_setting("enable_workflows") && user && @document&.workflow_step_id && @document.assigned_to?(user)
    # TODO: refactor \/this\/
    if workflow_authorized
      true
    elsif @organization.root_org_setting("enable_anonymous_actions")
      true
    elsif has_role('designer')
      true
    elsif is_authorized && @document == nil
      true
    elsif is_authorized && lms_course_id == nil
      true
    elsif is_authorized && authorized_to_edit_course(lms_course_id)
      true
    else
      false
    end
  end

  def authorized_to_edit_course lms_course_id
    if @lms_type == 'canvas'
      course = get_canvas_course lms_course_id
    else
      course = nil
    end

    user = current_user
    
    workflow_authorized = @organization.root_org_setting("enable_workflows") && user && @document.workflow_step_id && @document.assigned_to?(user)

    if workflow_authorized
      true
    elsif is_lti_authenticated_course?(lms_course_id)
      true
    elsif course != nil && course['id'] == lms_course_id.to_i
      true
    else
      false
    end
  end

  def get_canvas_course lms_course_id
    lms_connection_information
    canvas_access_token = session[:canvas_access_token]["access_token"]
    canvas = Canvas::API.new(:host => session[:oauth_endpoint], :token => canvas_access_token)
    course = canvas.get("/api/v1/courses/#{lms_course_id}")
  end

  def is_lti_authenticated_course? lms_course_id
    return (session.key?('lti_info') && session[:lti_info]['course_id'] == lms_course_id)
  end

  def is_saml_authenticated_user?
    if session[:saml_authenticated_user]
      true
    else
      false
    end
  end

  def has_canvas_access_token?
    if session[:canvas_access_token] != nil && session[:canvas_access_token] != ""
      true
    else
      false
    end
  end

  def view_pdf_url
    if Rails.env.production?
      "https://s3-#{APP_CONFIG['aws_region']}.amazonaws.com/#{APP_CONFIG['aws_bucket']}/hosted/#{@document.view_id}.pdf"
    else
      "http://#{request.env['SERVER_NAME']}#{redirect_port}/#{sub_org_slugs}SALSA/#{@document.view_id}.pdf"
    end
  end

  def view_url
    "http://#{request.env['SERVER_NAME']}#{redirect_port}/#{sub_org_slugs}SALSA/#{@document.view_id}"
  end

  def template_url document
    "http://#{request.env['SERVER_NAME']}#{redirect_port}/#{sub_org_slugs}SALSA/#{document.template_id}"
  end

  def sub_org_slugs
    params[:org_path] + '/' if params[:org_path]
  end

  def lookup_document
    @document = Document.find_by_edit_id(params[:id])

    raise ActionController::RoutingError.new('Not Found') unless @document
    @view_pdf_url = view_pdf_url
    @view_url = view_url
    @template_url = template_url(@document)

    # use the component that was used when this document was created
    if @document.component_version
      @document.component.revert_to @document.component_version
    end

    # backwards compatibility alias
    @syllabus = @document
  end

  def update_course_document course_id, html, lms_info_slug, lms_client, document=nil
    lms_connection_information

    lms_client.put("/api/v1/courses/#{course_id}", { course: { syllabus_body: html } })

    if(lms_info_slug)
      lms_client.put("/api/v1/courses/#{course_id}/#{lms_info_slug}", { wiki_page: { body: "<p><a id='edit-gui-salsa' href='#{ document_url(@document[:edit_id]) }' target='_blank'>Edit your <abbr title='Styled and Accessible Learning Service Agreement'>SALSA</abbr></a></p>", hide_from_students: true } })
    end

    if document
      document.update(lms_published_at: DateTime.now, lms_course_id: course_id)
    end
  end

  def verify_org
    document_slug = get_org_slug

    if @document[:edit_id]
      @salsa_link = document_path(@document[:edit_id],org_path: params[:org_path])

    end

    if @organization && @organization[:id]
      org = @organization
    else
      if session[:authenticated_institution] && session[:authenticated_institution] != '' && session[:authenticated_institution] != document_slug
        document_slug = session[:authenticated_institution] + '.' + document_slug
      end

      # find the org to bind this to
      org = find_org_by_path(get_org_path)
    end

    # if there is no org yet, show an error
    raise "error: no org found matching #{document_slug}"  unless org

    @document[:organization_id] = org[:id] if @document && (!org.root_org_setting("enable_workflows") || @document.new_record?)

    @organization = org
  end
end
