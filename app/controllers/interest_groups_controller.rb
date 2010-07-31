class InterestGroupsController < ApplicationController
  filter_resource_access

  def index
    params[:subjects] ||= []
    @interest_groups =
      if params[:term].present?
        InterestGroup.paginated_search(params).results
      else
        InterestGroup.for_subjects(params[:subjects]).paginate(:order => 'name', :page => params[:page])
      end
    @subjects = Subject.tag_cloud_for_interest_groups_matching(params[:term]).all(:limit => 25)

    respond_to do |format|
      format.html
      format.js {
        render 'interest_groups/index', :layout => false
      }
    end
  end

  def show
    if !@interest_group.friendly_id_status.best?
      redirect_to interest_group_path(@interest_group), :status => 301
      return
    end
  end

  def new
  end

  def create
    if @interest_group.save
      flash[:notice] = "Successfully created interest group"
      redirect_to @interest_group
    else
      flash[:error] = "Unable to create interest group"
      render :action => :new
    end
  end

  def edit
  end

  def update
    if params[:report].present? && @interest_group.report.update_attributes(params[:report])
      flash[:notice] = "Successfully updated interest group"
      redirect_to @interest_group
    elsif @interest_group.update_attributes(params[:interest_group])
      flash[:notice] = "Successfully updated interest group"
      redirect_to @interest_group
    else
      flash[:error] = "Unable to update interest group"
      render :action => :edit
    end
  end

  protected

  def new_interest_group_from_params
    @interest_group = InterestGroup.new((params[:interest_group] || {}).reject {|k, v| v.blank? })
  end
end
