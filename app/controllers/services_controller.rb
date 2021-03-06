class ServicesController < ApplicationController
  before_action :set_service, only: %i[show edit update destroy]
  before_action :authenticate_user!, except: %i[index show]
  before_action :required_creator, only: %i[edit update destroy]
  before_action :check_file, only: %i[import]
  PER_PAGE = 12

  def index
    @services = Service.search_open_status
    # @clip = current_user.clips.build
    # カテゴリーで絞り込み
    @services = @services.search_with_category(params[:category_id]) if params[:category_id]

    # 検索機能
    @services = @services.search(params[:search]) if params[:search]

    # ソート機能
    @services = @services.sort_name if params[:sort_name] # 名前順
    @services = @services.sort_create if params[:sort_create] # 新着順
    @services = @services.sort_update if params[:sort_update] # 更新順
    @services = @services.sort_with_user_count if params[:sort_with_rank] # 人気順
    @services = @services.search_with_using(current_user) if params[:search_with_using] # 利用中のみ
    @services = current_user.clipped_services if params[:sort_clipped] # 気になるサービスのみ
    @services = Service.search_secret_status.search_with_user_id(current_user) if params[:sercet_index] # オリジナルのみ

    # CSV出力
    respond_to do |format|
      format.html
      format.csv { send_data @services.generate_csv, filename: "service-#{Time.zone.now.strftime('%Y%m%d%S')}.csv" }
    end

    # ページネーション
    @services = @services.page(params[:page]).per(PER_PAGE).sort_name.includes(:categories)
  end

  def new
    @service = Service.new
  end

  def create
    @service = Service.new(service_params)
    @service.user_id = current_user.id
    @service.status = 'secret' unless current_user.admin?
    if @service.save
      Subscription.create(user_id: current_user.id, service_id: @service.id) if @service.status == 'secret'
      redirect_to services_path, notice: "「#{@service.name}」を登録しました"
    else
      render 'new'
    end
  end

  def show; end

  def edit; end

  def update
    if @service.update(service_params)
      redirect_to services_path, notice: "「#{@service.name}」を更新しました"
    else
      render 'edit'
    end
  end

  def destroy
    @service.destroy
    redirect_to services_path, alert: "「#{@service.name}」を削除しました"
  end

  # CSVインポート
  def import
    Service.import(params[:file])
    redirect_to services_path, notice: 'CSVをインポートしました'
  end

  private

  def set_service
    @service = Service.find(params[:id])
  end

  def service_params
    params.require(:service).permit(
      :name, :icon, :icon_cache, :link, :summary, :status, category_ids: []
    )
  end

  def check_file
    redirect_to services_path, alert: 'CSVファイルを選択してください' if params[:file].nil?
  end
end
