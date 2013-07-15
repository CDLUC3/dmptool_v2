module OmniAuth
  module Strategies
    autoload :Shibboleth, File.join(Rails.root, 'lib', 'omniauth_shibboleth')
  end
end

shib_config = YAML.load_file(File.join(Rails.root, 'config', 'shibboleth.yml'))

omniauth_config = shib_config['omniauth_config']

#TODO exactly how this is called for the DMPtool is not known yet. Have to coordinate it with lib/omniauth_shibboleth
#where the strategy is actually defined. It may be, for example, that the url to use for redirect gets
#passed in (since there will be more than one of them), etc. I don't have experience with multiple identity
#providers yet.
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shibboleth, omniauth_config['redirect_url'], omniauth_config['return_base_url']
end


