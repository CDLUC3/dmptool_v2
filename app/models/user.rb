class User < ActiveRecord::Base

  belongs_to :institution
  has_many :user_plans
  has_many :plans, through: :user_plans
  has_many :comments
  has_one :authentication

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :institution_id, presence: true, numericality: true
  validates :email, presence: true, uniqueness: { :case_sensitive => false }, format: { with: VALID_EMAIL_REGEX }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :prefs, presence: true

  before_validation :create_default_preferences

  def create_default_preferences
    if prefs.nil?

      default_prefs = {
          users:                   {
              role_granted: true
          },
          dmp_owners_and_co:       {
              new_comment: true,
              commited:    true,
              published:   true,
              submitted:   true
          },
          dmp_co:                  {
              submitted:    true,
              deactivated:  true,
              deleted:      true,
              new_co_owner: true
          },
          requirement_editors:     {
              commited:  true,
              deactived: true,
              deleted:   true
          },
          resource_editors:        {
              commited:            true,
              deactived:           true,
              deleted:             true,
              associated_commited: true
          },
          institutional_reviewers: {
              submitted:         true,
              new_comment:       true,
              approved_rejected: true
          }
      }

      self.prefs = default_prefs

    end
  end
end
