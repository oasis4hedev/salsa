class PeriodsController < Admin::PeriodsController

  before_action :redirect_to_sub_org, only:[:index,:new,:show,:edit]
  before_action :get_organizations, only: [:index, :new, :edit, :create, :update]
  before_action :require_organization_admin_permissions

  def index
    @organization = find_org_by_path(params[:slug])
    @periods = Period.where(organization_id: @organization.id)
    super
  end

  def new
    @organization = find_org_by_path(params[:slug])
    super
  end

  def show
    @organization = find_org_by_path(params[:slug])
    super
  end

  def edit
    @organization = find_org_by_path(params[:slug])
    super
  end

  # POST /periods
  # POST /periods.json
  def create
    @organization = find_org_by_path(params[:slug])
    @period = Period.new(period_params)
    @period.organization_id = @organization.id
    respond_to do |format|
      if @period.save
        format.html { redirect_to periods_path(params[:slug], org_path: params[:org_path]), notice: 'Period was successfully created.' }
        format.json { render :index, status: :created }
      else
        format.html { render :new }
        format.json { render json: @period.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @organization = find_org_by_path(params[:slug])
    @period = Period.find(params[:id])
    @period.organization_id = @organization.id
    respond_to do |format|
      if @period.update(period_params)
        format.html { redirect_to periods_path(params[:slug], org_path: params[:org_path]), notice: 'Period was successfully updated.' }
        format.json { render :index, status: :ok}
      else
        format.html { render :edit }
        format.json { render json: @period.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def find_or_create_period
    end


  def period_params
    params.require(:period).permit(:name, :slug, :start_date, :duration, :is_default)
  end
end
