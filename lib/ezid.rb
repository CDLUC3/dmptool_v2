require 'net/http'
require 'uri'
require 'openssl'

module Ezid
  class MintException < Exception ; end

  class Minter
    def initialize(uri_string, username, pwd)
      @uri, @user, @pwd = URI.parse(uri_string), username, pwd
    end

    def mint
      return mint_it
    end

    private

    def mint_it
      begin
        Net::HTTP.start(@uri.host, @uri.port,
            :use_ssl => @uri.scheme == 'https',
            :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

          request = Net::HTTP::Post.new(@uri.request_uri, initheader = { 'Content-Type' => 'text/plain; charset=UTF-8'})
          #request.body = "_target: http://www.cdlib.org/\r\nerc.who: Bob"
          request.basic_auth @user, @pwd

          response = http.request request

          if response.body.start_with?('success:')
            return response.body.split()[1]
          else
            raise MintException.new("Minting unsuccessful.")
          end
        end
      rescue SocketError
        raise MintException.new("Could not connect to server.")
      rescue Exception
        raise MintException.new("Can't get ID; not a EZID server?")
      end
    end
  end
end