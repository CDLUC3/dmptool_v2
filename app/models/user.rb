class User < ActiveRecord::Base

  include UserEmail

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

  scope :active, -> { where(active: true, deleted_at: nil) }

  accepts_nested_attributes_for :user_plans

  attr_accessor :ldap_create, :password, :password_confirmation

  VALID_EMAIL_REGEX = /\A[^@]+@[^@]+\.[^@]+\z/i #very simple, but requires basic format and emails are nearly impossible to validate anyway
  validates :institution_id, presence: true, numericality: true
  validates :email, presence: true, uniqueness: true ,format: { with: VALID_EMAIL_REGEX }
  validates :prefs, presence: true
  validates :login_id, presence: true, uniqueness: { case_sensitive: false }, :if => :ldap_create

  before_validation :create_default_preferences, if: Proc.new { |x| x.prefs.empty? }
  before_validation :add_default_institution, if: Proc.new { |x| x.institution_id.nil? }

  def ensure_ldap_authentication(uid)
    unless Authentication.find_by_user_id_and_provider(self.id, 'ldap')
      Authentication.create(:user => self, :provider => 'ldap', :uid => uid)
    end
  end

  def self.from_omniauth(auth, institution_id)
    uid = smart_userid_from_omniauth(auth)
    return nil if uid.blank? || unpicky(auth, :info).blank? || unpicky(unpicky(auth, :info), :email).blank?
    a = Authentication.find_by_uid(uid)
    (a.nil? ? nil: a.user) || create_from_omniauth(auth, institution_id)
  end

  def self.create_from_omniauth(auth, institution_id)
    info = unpicky(auth, :info)
    email = unpicky(info, :email)
    user = User.find_by_email(email)
    ActiveRecord::Base.transaction do
      if user.nil?
        user = User.new
        user.email = smart_email_from_omniauth(email)
        # Set any of the omniauth fields that have values  in the database.
        # The keys are the omniauth field names, the values are the database field names
        # for mapping omniauth field names to db field names.
        {:first_name => :first_name, :last_name => :last_name}.each do |k, v|
          user.send("#{v}=", unpicky(info, k)) if !unpicky(info, k).blank?
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
    info = unpicky(auth, :info)
    uid = (info ? unpicky(info, :uid) : nil) || unpicky(auth, :uid)
    if uid.match(/^uid=\S+?,ou=\S+?,ou=\S+?,dc=\S+?,dc=\S+?$/)
      return uid.match(/^uid=(\S+?),ou=\S+?,ou=\S+?,dc=\S+?,dc=\S+?$/)[1]
    end
    uid
  end

  #fixes weird emails
  def self.smart_email_from_omniauth(email)
    e = email
    if email.class == Array
      e = email.first
    end
    matches = e.match(/(^.*?)[;,]/i)
    if matches
      e = matches[1]
    end
    e
  end

  def self.search_terms(terms)
    items = terms.split
    conditions1 = items.map{|item| "CONCAT(first_name, ' ', last_name) LIKE ?" }
    conditions2 = items.map{|item| "email LIKE ?" }
    conditions = "( (#{conditions1.join(' AND ')})" + ' OR ' + "(#{conditions2.join(' AND ')}) )"
    values = items.map{|item| "%#{item}%" }
    self.where(conditions, *(values * 2) )
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def full_name_last_first
    [last_name, first_name].join(" ")
  end


  #label for dropdown for autocomplete
  def label
    "#{self.full_name} <#{self.email}>"
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


  def has_any_role?
    self.authorizations.count > 0
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

  #this takes an array of numeric role ids and will update that user to have those role ids by deleting and adding as needed
  def update_authorizations(role_ids)
    role_ids = role_ids.map {|i| i.to_i }
    roles = self.roles.collect(&:id) # get current role ids
    roles_to_remove = roles - role_ids
    roles_to_add = role_ids - roles

    unless roles_to_remove.blank?
      self.authorizations.where(role_id: roles_to_remove).destroy_all
    end

    unless roles_to_add.blank?
      roles_to_add.each do |r|
        self.authorizations.create({:role_id => r})
      end
      email_roles_granted(roles_to_add)
    end
    return {:roles_added => roles_to_add, :roles_removed => roles_to_remove}
  end

  private

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

  def self.unpicky(hash, key)
    hash[key.intern] || hash[key.to_s]
  end
end
