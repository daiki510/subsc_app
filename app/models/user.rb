class User < ApplicationRecord
  has_many :services, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :services, through: :subscriptions, source: :service
  has_many :clips, dependent: :destroy
  has_many :clipped_services, through: :clips, source: :service

  validates :name, presence: true, length: { maximum: 30 }
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[google]

  enum notification_status: { notifications_off: 0, notifications_one: 1, notifications_two: 2 }

  scope :search_with_category, ->(category_id) { where(id: category_ids = Categorizing.where(category_id: category_id).select(:service_id)) }
  scope :sort_name, -> { order(name: :asc) }
  scope :sort_create, -> { order(created_at: :desc) }

  class << self
    # 検索メソッド
    def search(search)
      return where(['name LIKE ?', "%#{search}%"]) if search

      all
    end

    # oauth認証
    def from_omniauth(auth)
      user = User.find_by(email: auth.info.email)
      user ||= User.new(
        email: auth.info.email,
        provider: auth.provider,
        uid: auth.uid,
        name: auth.info.name,
        password: Devise.friendly_token[0, 20]
      )
      user.save
      user
    end

    # 新規登録時にuidカラムをランダムに自動生成
    def create_unique_string
      SecureRandom.uuid
    end
  end
end
