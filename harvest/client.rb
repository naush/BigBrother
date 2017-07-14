require 'json'
require 'net/http'
require 'uri'
require 'openssl'
require 'base64'

module Harvest
  class Client
    def initialize(subdomain:, email:, password:)
      @subdomain = subdomain
      @email = email
      @password = password
    end

    def authorization
      Base64.encode64("#{@email}:#{@password}").delete("\r\n")
    end

    def headers
      {
        "Accept"        => "application/json",
        "Content-Type"  => "application/json",
        "Authorization" => "Basic #{authorization}",
        "User-Agent"    => "BIG_BROTHER"
      }
    end

    def host
      "#{@subdomain}.harvestapp.com"
    end

    def connection
      http = Net::HTTP.new(host, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http
    end

    def people(filters={})
      uri = URI.parse("https://#{host}/people")
      response = connection.get(uri.request_uri, headers)
      json = JSON.parse(response.body)
      people = json.collect { |object| object['user'] }

      people.select do |person|
        filters.all? do |key, value|
          person[key] == value
        end
      end
    end

    def time_entries(person_id:, from:, to:)
      uri = URI.parse("https://#{host}/people/#{person_id}/entries")
      params = { from: from, to: to }
      uri.query = URI.encode_www_form(params)
      response = connection.get(uri.request_uri, headers)
      JSON.parse(response.body)
    end
  end
end
