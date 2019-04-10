module ServicesHelper
  include Common
  def total_services(services)
    services.count
  end

  # 追加されたサブスクリプションかどうか
  def already_added?(service)
    subscriptions.where(service_id: service.id).present?
  end

  def categories
    Category.all
  end
end
