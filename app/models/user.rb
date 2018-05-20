require 'users_helper'

class User < ActiveRecord::Base
  belongs_to :referrer, class_name: 'User', foreign_key: 'referrer_id'
  has_many :referrals, class_name: 'User', foreign_key: 'referrer_id'

  validates :email, presence: true, uniqueness: true, format: {
    with: /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/i,
    message: 'Invalid email format.'
  }
  validates :referral_code, uniqueness: true

  before_create :create_referral_code
  after_create :send_welcome_email

  REFERRAL_STEPS = [
    {
      'count' => 5,
      'html' => 'Froot Pack x1',
      'class' => 'two',
      'image' =>  'refer/tier1.png'
    },
    {
      'count' => 10,
      'html' => 'Froot Pack x3',
      'class' => 'three',
      'image' =>  'refer/tier2.png'
    },
    {
      'count' => 25,
      'html' => 'Froot Pack<br>6 Month Supply',
      'class' => 'four',
      'image' =>  'refer/tier3.png'
    },
    {
      'count' => 50,
      'html' => 'Froot Pack<br>1 Year Supply',
      'class' => 'five',
      'image' =>  'refer/tier4.png'
    }
  ]

  private

  def create_referral_code
    self.referral_code = UsersHelper.unused_referral_code
  end

  def send_welcome_email
    UserMailer.delay.signup_email(self)
  end
end
