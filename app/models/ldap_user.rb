class Ldap_User
  LDAP = UserLdap::Server.
      new({ :host            => LDAP_CONFIG["host"],
            :port            => LDAP_CONFIG["port"],
            :base            => LDAP_CONFIG["user_base"],
            :admin_user      => LDAP_CONFIG["admin_user"],
            :admin_password  => LDAP_CONFIG["admin_password"],
            :minter          => LDAP_CONFIG["ark_minter_url"]})

  AUTHLOGIC_MAP =
      { 'login'         => 'uid',
        'lastname'      => 'sn',
        'firstname'     => 'givenname',
        'email'         => 'mail',
        'tz_region'     => 'tzregion'}

  def initialize(*args)
    if args.length == 1 and args[0].class == Net::LDAP::Entry then
      @ldap_user = args[0]
    #elsif args.length == 1 and args[0].class == Hash then
    end
  end

  def self.find_all
    LDAP.find_all
  end

  def method_missing(meth, *args, &block)
    #simple code to read user information with methods that resemble activerecord slightly
    if !AUTHLOGIC_MAP[meth.to_s].nil? then
      return array_to_value(@ldap_user[AUTHLOGIC_MAP[meth.to_s]])
    end
    array_to_value(@ldap_user[meth.to_s])
  end

  def self.find_by_id(user_id)
    u = LDAP.fetch(user_id)
    self.new(u)
  end

  def self.find_by_email(email)
    u = LDAP.fetch_by_email(email)
    self.new(u)
  end

  def change_password(new_password)
    LDAP.change_password(self.dn, new_password)
  end

  def set_attrib(attribute, value)
    LDAP.replace_attribute(self.login, attribute, value)
  end

  def set_attrib_dn(attribute, value)
    LDAP.replace_attribute_dn(self.dn, attribute, value)
  end

  def self.valid_ldap_credentials?(uid, password)
    begin
      res = Ldap_User::LDAP.authenticate(uid, password)
    rescue LdapMixin::LdapException => ex
      return false
    end
    return res && true
  end

  def single_value(record, field)
    if record[field].nil? or record[field][0].nil? or record[field][0].length < 1 then
      return nil
    else
      return record[field][0]
    end
  end

  def array_to_value(arr)
    return arr if !arr.is_a?(Array)
    return arr[0] if arr.length == 1
    arr
  end

  def self.add(login_id, password, first_name, last_name, email)
    LDAP.add(login_id, password, first_name, last_name, email)
  end

end