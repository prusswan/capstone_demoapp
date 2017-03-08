class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable
          #:confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  has_many :roles, inverse_of: :user, dependent: :destroy

  belongs_to :image

  scope :with_images, -> { where.not(image_id: nil) }

  def has_role(role_list, mname=nil, mid=nil)
    role_names=roles.relevant(mname, mid).map {|r| r.role_name}
    (role_names & role_list).any?
  end

  def add_role role_name, object
    if object.is_a?(Class)
      self.roles.find_or_initialize_by(:role_name=>role_name,
                     :mname=>object.name,
                     :mid=>nil)
    else
      self.roles.find_or_initialize_by(:role_name=>role_name,
                     :mname=>object.model_name.name,
                     :mid=>object.id)
    end
  end

  def add_roles role_name, items
    items.each {|item| add_role(role_name, item)}
    self
  end

  def is_admin?
     roles.where(:role_name=>Role::ADMIN).exists?
  end

  def image_url
    Rails.application.routes.url_helpers.image_content_path(self.image) if image_id
  end

  def token_validation_response
    self.as_json(except: [
      :tokens, :created_at, :updated_at
    ], methods: :image_url)
  end
end
