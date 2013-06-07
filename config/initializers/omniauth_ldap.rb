LDAP_CONFIG = YAML.load_file(Rails.root.join("config","ldap.yml"))[Rails.env]

Rails.application.config.middleware.use OmniAuth::Strategies::LDAP,
    :title => LDAP_CONFIG['omniauth_title'],
    :host => LDAP_CONFIG['host'],
    :port => LDAP_CONFIG['port'],
    :method => LDAP_CONFIG['omniauth_method'],
    :base => LDAP_CONFIG['user_base'],
    :uid => LDAP_CONFIG['omniauth_uid'],
    :bind_dn => LDAP_CONFIG['admin_user'],
    :password => LDAP_CONFIG['admin_password'],
    :allow_anonymous => false