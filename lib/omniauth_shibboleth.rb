module OmniAuth
  module Strategies
    class Shibboleth
      include OmniAuth::Strategy

      attr_accessor :base_url, :application_url

      #receive and save any needed parameters for the strategy
      args [:base_url, :application_url]


      #def initialize(app, base_url, application_url, options = {})
      #  self.base_url = base_url
      #  self.application_url = application_url
      #  super(app, :shibboleth, options)
      #end

      #redirect to shibboleth login
      #if a shibboleth domain doesn't come through then redirect to the LDAP login page instead.
      def request_phase
        domain = request.env['rack.request.query_hash']['shib_domain']
        r = Rack::Response.new
        r.redirect shibboleth_login_url(domain)
        r.finish
      end

      #check to see if we have a successful authentication
      def callback_phase
        if shibboleth_attribute('eppn')
          super
        else
          fail!(CGI.escape("No eppn for Shibboleth authentication."))
        end
      end

      #def auth_hash
      #  eppn = shibboleth_attribute('eppn')
      #  mail = parse_email(shibboleth_attribute('mail'))
      #  OmniAuth::Utils.deep_merge(super, {
      #      'user_info' => {'email' => mail, 'domain' => eppn.split('@').last},
      #      'uid' => eppn
      #  })
      #end

      uid { shib_eppn }

      info do
        {
            'email' => shib_mail,
            'domain' => shib_eppn.split('@').last
        }
      end

      protected

      def shib_mail
        parse_email(shibboleth_attribute('mail'))
      end

      def shib_eppn
        shibboleth_attribute('eppn')
      end

      def shibboleth_login_url(domain)
        url = self.base_url
        return "#{url}?target=#{shibboleth_target()}&entityID=#{shibboleth_entity_id(domain)}"
      end

      def shibboleth_target
        root = URI.parse(self.application_url)
        root.scheme = 'https'
        root.merge!('/auth/shibboleth/callback')
        CGI.escape(root.to_s)
      end

      def shibboleth_entity_id(domain)
        institution = Institution.find_by_shib_domain(domain)
        CGI.escape(institution.shib_entity_id)
      end

      #Do this in a way that (I think) will work with the attribute passed either by environment variables or header
      #The latter may be needed in some proxying situations - note that I'm not sure that this is the right formula
      #yet.
      def   shibboleth_attribute(name)
        #request.env.each {|k, v| puts "#{k.to_s}: #{v.to_s}"} #For debugging
        [request.env[name.to_s], request.env["HTTP_#{name.to_s.upcase.gsub('-', '_')}"]].detect { |att| att.present? }
      end

      def parse_email(mail)
        if (position = mail.index(';')) == nil
          return mail
        else
          return mail.slice!(0..(position-1))
        end
      end

    end

  end
end

