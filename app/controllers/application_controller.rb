class ApplicationController < ActionController::Base
  # deviseコントローラーにストロングパラメータを追加
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # 登録時のストロングパラメータを追加
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name admin notification_status])
    # 編集時のストロングパラメータを追加
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name admin notification_status])
  end

  def after_sign_in_path_for(resource)
    user_path(resource)
  end

  def after_sign_out_path_for(_resource)
    flash[:alert] = 'ログアウトしました'
    root_path
  end

  def required_admin
    redirect_to user_path(current_user.id), notice: '権限がありません' unless current_user.admin?
  end

  def required_creator
    service = Service.find(params[:id])
    unless current_user.admin?
      redirect_to user_path(current_user.id), notice: '権限がありません' if current_user.id != service.user_id
    end
  end

  def ensure_correct_user
    @user = User.find(params[:id])
    redirect_to user_path(current_user.id), notice: '権限がありません' if current_user.id != @user.id && current_user.admin == false
  end
end
