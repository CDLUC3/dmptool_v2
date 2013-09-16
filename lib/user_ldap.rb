module UserLdap
  class Server

    include LdapMixin

    def find_all
      return @admin_ldap.search(:base => @base,
                                :filter => (Net::LDAP::Filter.eq('objectclass', 'inetOrgPerson') &
                                    Net::LDAP::Filter.eq('objectclass', 'dmpUser')),
                                :scope => Net::LDAP::SearchScope_SingleLevel).
          sort_by{ |user| user['cn'][0].downcase }
    end

    def add(userid, password, firstname, lastname, email)
      attr = {
          :objectclass           => ["inetOrgPerson", 'dmpUser'],
          :uid                   => userid,
          :sn                    => lastname,
          :givenName             => firstname,
          :cn                    => "#{firstname} #{lastname}",
          :displayName           => "#{firstname} #{lastname}",
          :userPassword          => password,
          :arkId                 => "ark:/13030/#{@minter.mint}",
          :mail                  => email
      }
      true_or_exception(@admin_ldap.add(:dn => ns_dn(userid), :attributes => attr))
    end

    def authenticate(userid, password)
      raise LdapException.new('user does not exist') if !record_exists?(userid)
      @admin_ldap.bind_as(:base => @base, :filter => Net::LDAP::Filter.eq('uid', userid), :password => password)
    end

    def change_password(user_dn, password)
      result = replace_attribute_dn(user_dn, :userPassword, password)
      true_or_exception(result)
    end

    def ns_dn(id)
      "uid=#{id},#{@base}"
    end

    def obj_filter(id)
      Net::LDAP::Filter.eq("uid", id)
    end
  end
end
