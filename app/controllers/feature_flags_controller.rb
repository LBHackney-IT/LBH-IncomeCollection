class FeatureFlagsController < ApplicationController
  def index; end

  def activate
    FeatureFlag.activate(params[:feature_name])
    redirect_to feature_flags_dashboard_path
  end

  def deactivate
    FeatureFlag.deactivate(params[:feature_name])
    redirect_to feature_flags_dashboard_path
  end
end
