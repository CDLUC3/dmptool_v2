require 'net/http'
require 'uri'
require 'openssl'

module Ezid
  class MintException < Exception ; end

  class Minter
    def initialize(uri_string, username, pwd)
      @uri, @user, @pwd = URI.parse(uri_string), username, pwd
    end

    def mint_erc(who, what, whn)
      return mint_it("erc.who: #{escape(who)}\nerc.what: #{escape(what)}\nerc.when: #{escape(whn)}")
    end

    private

    def mint_it(body_metadata)
      begin
        Net::HTTP.start(@uri.host, @uri.port,
            :use_ssl => @uri.scheme == 'https',
            :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

          request = Net::HTTP::Post.new(@uri.request_uri, initheader = { 'Content-Type' => 'text/plain; charset=UTF-8'})
          request.body = body_metadata
          request.basic_auth @user, @pwd

          response = http.request request

          if response.body.start_with?('success:')
            return response.body.split()[1]
          else
            raise MintException.new("Minting unsuccessful: #{response.body}")
          end
        end
      rescue SocketError
        raise MintException.new("Could not connect to server.")
      rescue Exception => ex
        raise MintException.new("Can't get ID; not a EZID server?")
      end
    end

    def escape(str)
      str.gsub('%', '%25').gsub('\n', '%0A').
          gsub('\r', '%0D').gsub(':', '%3A')
    end
  end
end