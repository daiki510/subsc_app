class UsersController < ApplicationController
  include Common
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:show]
  PER_PAGE = 10

  def show
    @subscriptions = subscriptions
    @services = current_user.services

    # 検索機能
    @services = @services.search(params[:search]) if params[:search]

    # ソート機能
    @services = @services.sort_name if params[:sort_name] # 名前順
    @services = @services.sort_create if params[:sort_create] # 新着順
    @services = @services.search_with_unregisterd(current_user) if params[:sort_unregistered] # 詳細未登録のみ
    @services = @services.sort_charge if params[:sort_charge] # 利用料金順
    @services = @services.sort_date if params[:sort_date] # 支払日順

    # ページネーション
    @services = @services.page(params[:page]).per(PER_PAGE).includes(:categories)
  end
end
