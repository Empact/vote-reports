class User < ActiveRecord::Base
  is_gravtastic!
  has_friendly_id :username, :use_slug => true

  acts_as_authentic

  has_many :rpx_identifiers, :class_name => 'RPXIdentifier'
  has_many :reports

  validates_uniqueness_of :username, :email, :case_sensitive => false

  state_machine :initial => :active do
    event :disable do
      transition :active => :disabled
    end
  end

  class << self
    def find_by_username_or_email(login)
      find_by_smart_case_login_field(login) || find_by_email(login)
    end
  end

  def admin?
    false
  end
end
