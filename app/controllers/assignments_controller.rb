class AssignmentsController < AdminController
  layout :set_layout
  
  before_action :set_assignment, only: %i[show edit update destroy]
  before_action :check_organization_workflow_enabled
  before_action :set_roles, only: %i[edit workflows show new index create update]
  before_action :set_users
  before_action :set_namespace
  before_action :get_organizations, only: %i[index workflows new edit create show]
  before_action :require_supervisor_permissions, except: [:workflows]
  before_action :require_management_permissions, only: [:workflows]

  # GET /assignments
  # GET /assignments.json
  def index
    @assignment = Assignment.new
    get_org_time_zone

  end

  # GET /assignments/1
  # GET /assignments/1.json
  def show
  end

  def workflows
    @documents = @user.documents.where.not(workflow_step_id: nil).order('created_at DESC')

    if params[:document_id]
      @documents = [@documents.find(params[:document_id].to_i)]
    end

    @has_assignments = has_role("supervisor") || has_role("approver") || @direct_assignments.include?('approver') || @direct_assignments.include?('supervisor')

    @workflow_steps = {}
    @assignees = {}
    @statuses = {}

    @documents.each do |document|
      @statuses[document.id] = {}
      @assignees[document.id] = {}
      workflow_steps = []
      current_step_index = nil

      step = document.workflow_step

      if step.step_type != 'start_step'
        # get the start step for this workflow
        # loop previous until start...
        prev_index = 0
        loop do
          prev_step = step.previous_step

          if prev_step == nil || prev_index > 20
            step = nil
            break
          end
          
          step = prev_step
          if step.step_type == 'start_step'
            break
          end
          
        end
        prev_index += 1
      end

      if step == nil
        break
      end

      workflow_step_index = 0
      loop do
        workflow_steps.push step

        if step.next_workflow_step_id == nil || workflow_steps.length > 20
          break
        end

        step = WorkflowStep.includes(:component).find step.next_workflow_step_id

        if step.id == document.workflow_step_id
          current_step_index = workflow_step_index
        end
        
        if step.component != nil && step.component.role != ''
          role = step.component.role

          # find all direct assigned for role
          managers = document.closest_users_with_role role
          workflow_logs = WorkflowLog.where(document_id: document.id, step_id: step.id)
            .group(:user_id, :role).select(:user_id, :role)

          if workflow_logs.length == 0
            workflow_logs = nil
          end

          assigned_managers = @user.assignees.where(role: role).map(&:user)

          assignees = {
            'role' => role,
            'users' => assigned_managers + managers,
            'logs' => workflow_logs,
          }
          
          # add assignees by step id to @assignees for use in the view
          @assignees[document.id][step.id] = assignees
        end

        workflow_step_index += 1

      end

      workflow_steps.each_with_index do |step, index|
        if current_step_index != nil && current_step_index >= index
          @statuses[document.id][step.id] = true
        else
          @statuses[document.id][step.id] = false
        end
      end

      @workflow_steps[document.id] = workflow_steps.select { |step| ['supervisor', 'approver'].include?(step.component.role) }
    end

    get_org_time_zone

    render 'workflows'
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
  end

  # GET /assignments/1/edit
  def edit
  end

  # POST /assignments
  # POST /assignments.json
  def create
    @assignment = Assignment.new(assignment_params)
    if params[:assignment][:user_id].blank?
      @assignment.user_id = @user.id
    else
      @assignment.team_member_id = @user.id
    end

    respond_to do |format|
      if @assignment.save
        format.html { redirect_to eval("#{@namespace}_user_team_assignments_path"), notice: 'Assignment was successfully created.' }
        format.json { render :index, status: :created, location: @assignment }
      else
        format.html { render :index }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assignments/1
  # PATCH/PUT /assignments/1.json
  def update
    if params[:assignment][:user_id].blank?
      @assignment.user_id = @user.id
    else
      @assignment.team_member_id = @user.id
    end
    respond_to do |format|
      if @assignment.update(assignment_params)
        format.html { redirect_to @assignment, notice: 'Assignment was successfully updated.' }
        format.json { render :show, status: :ok, location: @assignment }
      else
        format.html { render :edit }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assignments/1
  # DELETE /assignments/1.json
  def destroy
    @assignment.destroy
    respond_to do |format|
      format.html { redirect_to eval("#{@namespace}_user_team_assignments_url"), notice: 'Assignment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_assignment
    @assignment = Assignment.find(params[:id])
  end

  def set_users
    get_organizations
    user_id = params[params.keys.detect { |k| k.to_s =~ /user_id/ }.to_sym].to_i

    @user = User.find(user_id)

    @assignments = @user.assignments
    @assignees = @user.assignees

    # todo - verify role for user
    if (@organizations.pluck(:id) & @user.user_assignments.pluck(:organization_id)).empty?
      raise ActionController::RoutingError.new('Not Authorized')
    end

    descendant_ua_ids = []
    find_org_by_path(params[:slug]).self_and_descendants.each do |org|
      descendant_ua_ids += org.user_assignments.pluck(:id)
    end
    @descendant_user_assignments = UserAssignment.where(id: descendant_ua_ids)
    @descendant_users = User.where(id: @descendant_user_assignments.pluck(:user_id) - [user_id])

    ancestor_user_ids = []
    find_org_by_path(params[:slug]).self_and_ancestors.each do |org|
      ancestor_user_ids += org.users.pluck(:id)
    end
    ancestor_user_ids = ancestor_user_ids - [user_id]
    @ancestor_users = User.where(id: ancestor_user_ids)




    user_assignment = @user.user_assignments.find_by(role: ["staff","supervisor"])
    @managers_up_tree = user_assignment&.workflow_roles&.where&.not(user_id: @assignees&.pluck(:user_id))
  end

  def set_roles
    @roles = { 'Supervisor' => 'supervisor', 'Approver' => 'approver' }
  end

  def set_namespace
    @namespace =
      if params.key?(:organization_user_id)
        :organization
      else
        :admin
      end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def assignment_params
    params.require(:assignment).permit(:role, :user_id, :team_member_id)
  end

  def set_layout
    if params[:action] != 'workflows'
      return 'admin'
    else
      return 'workflow'
    end
  end
end
