class Admin::ActivitiesController < AdminController
  before_action :require_primary_community

  def index
    @activities = current_region.activities
                                .where(event: Activity::NON_ACCOMPANIMENT_ELIGIBLE_EVENTS)
                                .includes(:friend, :location)
  end

  def accompaniments
    @activities = current_region.activities
                                .where(event: Activity::ACCOMPANIMENT_ELIGIBLE_EVENTS)
                                .includes(:accompaniments, :users, :accompaniment_reports, :friend, :location)
  end

  def new
    @activity = current_region.activities.new
  end

  def edit
    @activity = activity
  end

  def create
    @activity = current_region.activities.new(activity_params)
    activity.activity_type = ActivityType.find(name: activity.event)
    if activity.save
      flash[:success] = 'Activity saved.'
      redirect_to community_admin_activities_path(current_community.slug)
    else
      flash.now[:error] = 'Activity not saved.'
      render :new
    end
  end

  def update
    if activity.update(activity_params)
      flash[:success] = 'Activity saved.'
      if activity.accompaniment_eligible?
        redirect_to accompaniments_community_admin_activities_path(current_community.slug)
      else
        redirect_to community_admin_activities_path(current_community.slug)
      end
    else
      flash.now[:error] = 'Activity not saved.'
      render :edit
    end
  end

  def confirm
    if activity.update(confirmed: true)
      flash[:success] = 'Accompaniment confirmed.'
    else
      flash.now[:error] = 'There was an issue confirming this accompaniment.'
    end
    redirect_to accompaniments_community_admin_activities_path
  end

  def activity
    @activity ||= current_region.activities.find(params[:id])
  end

  private

  def activity_params
    params.require(:activity).permit(
      :event,
      :location_id,
      :friend_id,
      :judge_id,
      :occur_at,
      :notes,
      :public_notes
    )
  end
end
