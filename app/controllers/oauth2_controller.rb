require "#{Rails.root}/lib/canvas_api"
class Oauth2Controller < ApplicationController
  def login
    session[:canvas_access_token] = ''
    session[:authenticated_institution] = ''

    lms_connection_information

    session[:institution] = @institution
    session[:oauth_endpoint] = @oauth_endpoint 

    return redirect_to(@redirect_url) if @redirect_url
    return redirect_back(fallback_location: root_path)
  end

  def logout
    session[:institution] = ''
    session[:oauth_endpoint] = ''
    session[:canvas_access_token] = ''
    session[:authenticated_institution] = ''

    flash[:notice] = "You are disconnected from Canvas."

    redirect_back(fallback_location: root_path)
  end

  def callback
    lms_connection_information

    code = params[:code]

    if code
      token = CanvasApi.retrieve_access_token(code, @redirect_url, @lms_client.client_id, @lms_client.as_json["secret"], @lms_client.as_json["host"])
      session[:canvas_access_token] = token

      flash[:notice] = 'You are connected to Canvas.'

      session[:authenticated_institution] = session[:institution]
      session[:saml_authenticated_user] = session[:canvas_access_token]['user']
    else
      flash[:error] = params[:error]
    end

    lms_course_id = params[:lms_course_id]

    unless lms_course_id
      if session[:redirect_course_id]
        lms_course_id = session[:redirect_course_id]

        session[:redirect_course_id] = nil
      end
    end

    if lms_course_id
      if params[:document_token]
        redirect_to lms_course_document_path(lms_course_id, document_token: params[:document_token], org_path: params[:org_path])
      else
        redirect_to lms_course_document_path(lms_course_id, org_path: params[:org_path])
      end
    elsif params[:document_id] != ''
      redirect_to document_path(params[:document_id], org_path: params[:org_path]) + '#/select/course'
    else
      redirect_to admin_auditor_reports_path(org_path: params[:org_path])
    end
  end
end
