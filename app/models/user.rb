class User < ActiveRecord::Base

  acts_as_paranoid

  serialize :prefs, Hash

  belongs_to :institution
  has_many :user_plans
  has_many :plans, through: :user_plans
  has_many :comments
  has_many :authentications
  has_many :authorizations
  has_many :roles, through: :authorizations

  has_many :owned_plans, -> { where user_plans: { owner: true} }, through: :user_plans,
  source: :plan, class_name: 'Plan'

  has_many :coowned_plans, -> { where user_plans: { owner: false} }, through: :user_plans,
  source: :plan, class_name: 'Plan'

  accepts_nested_attributes_for :user_plans

  attr_accessor :ldap_create, :password, :password_confirmation

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :institution_id, presence: true, numericality: true
  validates :email, presence: true, uniqueness: true ,format: { with: VALID_EMAIL_REGEX }
  validates :prefs, presence: true
  validates :login_id, presence: true, uniqueness: { case_sensitive: false }, :if => :ldap_create

  before_validation :create_default_preferences, if: Proc.new { |x| x.prefs.empty? }
  before_validation :add_default_institution, if: Proc.new { |x| x.institution_id.nil? }
  before_create :create_cookie_salt, if: Proc.new { |x| x.cookie_salt.nil? }

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.cookie_salt == cookie_salt) ? user : nil
  end

  def ensure_ldap_authentication(uid)
    unless Authentication.find_by_user_id_and_provider(self.id, 'ldap')
      Authentication.create(:user => self, :provider => 'ldap', :uid => uid)
    end
  end

  def self.from_omniauth(auth, institution_id)
    uid = smart_userid_from_omniauth(auth)
    return nil if uid.blank? || auth[:info][:email].blank?
    a = Authentication.find_by_uid(uid)
    (a.nil? ? nil: a.user) || create_from_omniauth(auth, institution_id)
  end

  def self.create_from_omniauth(auth, institution_id)
    user = User.find_by_email(auth[:info][:email])
    ActiveRecord::Base.transaction do
      if user.nil?
        user = User.new
        user.email = auth[:info][:email]
        # Set any of the omniauth fields that have values  in the database.
        # The keys are the omniauth field names, the values are the database field names
        # for mapping omniauth field names to db field names.
        {:first_name => :first_name, :last_name => :last_name}.each do |k, v|
          user.send("#{v}=", auth[:info][k]) if !auth[:info][k].blank?
        end
        #fix login_id for CDL LDAP to be simple username
        user.login_id = smart_userid_from_omniauth(auth)
        user.institution_id = institution_id
        user.save!
      else
        user.institution_id = institution_id
        user.save!
      end

      Authentication.create!({:user_id => user.id, :provider => auth[:provider], :uid => smart_userid_from_omniauth(auth)})
    end
    user
  end

  #returns the userid from omniauth, for LDAP usernames we don't qualify it
  #while for shibboleth we have a longer qualified string which we need to distinguish
  #since an unqualified login or an email may not be unique
  def self.smart_userid_from_omniauth(auth)
    uid = auth[:info][:uid] || auth[:uid]
    if uid.match(/^uid=\S+?,ou=\S+?,ou=\S+?,dc=\S+?,dc=\S+?$/)
      return uid.match(/^uid=(\S+?),ou=\S+?,ou=\S+?,dc=\S+?,dc=\S+?$/)[1]
    end
    uid
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def plans_by_state(state)
    #get all plans this user has in the state specified
    Plan.joins(:current_state, :user_plans).
          where(:user_plans => { :user_id => self.id }).
          where(:plan_states => { :state => state})
  end

  def unique_plan_states
    #returns a list of the unique plan states that this user has
    Plan.joins(:current_state, :user_plans).
        where(:user_plans => { :user_id => self.id }).
        select('plan_states.state').distinct.pluck(:state)
  end

  def role_ids
    @role_id ||= self.authorizations.pluck(:role_id) #caches role ids
  end

  def role_names
    @role_names ||= self.roles.pluck(:name)
  end

  def has_role?(role_id)
    role_ids.include?(role_id)
  end

  def has_role_name?(role_name)
    role_names.include?(role_name)
  end

  private

  def create_cookie_salt
    self.cookie_salt = secure_hash("#{self.created_at}--UCOP--DMP")
  end

  def add_default_institution
    self.institution_id = 0
  end

  def create_default_preferences
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

  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end

  public

  #sets a new token if it's not set or is expired
  def ensure_token
    if self.token_expiration and Time.now > self.token_expiration
      self.token = nil
    end
    self.token ||= self.generate_token
    self.token_expiration = Time.now + 1.day
    self.save
    return self.token
  end

  def clear_token
    self.token = nil
    self.token_expiration = nil
    self.save
  end

  def ldap_user?
    self.authentications.where(:provider => 'ldap').first.present?
  end

  protected

  TOKEN_CHARS = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
  def generate_token
    40.times.collect {TOKEN_CHARS.sample}.join('')
  end
end
