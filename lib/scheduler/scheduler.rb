# lib/api-client/cli.rb

# frozen_string_literal: true

require 'pp'
require 'net/http'
require 'uri'
require 'json'
require 'digest'
require 'action_controller'
require 'open3'

module ApiClient
  # A minimal layer over net/http to simplify sending requests to Client API
  class Http

    attr_reader :url, :token

    API_URLS = {
      staging: 'http://projectname-staging.client.com/api/v1',
      development: 'http://localhost:3000'
    }.freeze

    METHODS = { post: Net::HTTP::Post, put: Net::HTTP::Put, get: Net::HTTP::Get }.freeze

    def initialize(environment = 'development', token = nil)
      @url = API_URLS[environment.to_sym]
      @token = token

      throw "Environment not valid: #{environment}" if @url.blank?
    end

    def authorization
      return true
      return '' if @token.blank?

      nonce = Time.now.to_i
      token = Digest::SHA256.hexdigest("#{@token}#{nonce}")
      ActionController::HttpAuthentication::Token.encode_credentials(token, nonce: nonce)
    end

    def send_request(method, url, body = nil)
      url=@url+url
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = METHODS[method].new(uri.try(:request_uri) || uri.to_s, header)
      request.body = body.to_json if body.present?
      http.request(request)
    end

    def header
      {
        'Content-Type' => 'application/json',
        # 'Authorization' => authorization
      }
    end

  end
end

class Scheduler
  def handle_notification(msg)
    choices=['Done', 'Already Done', 'Snooze', 'Skip']
    stdout, stderr, status = Open3.capture3('rofi-choices', msg, *choices)
    choice=stdout.chomp
    if choice == 'Snooze'
      stdout, stderr, status = Open3.capture3('rofi', '-dmenu', '-l', '0', '-p', 'Snooze for how long?')
    end
    return stdout.chomp
  end

  def snooze(id, time)
    response = @client.send_request(:put, '/notifications/snooze.json', id: id, time: time)
    handle_response(response)
  end

  def mark_as(id, state)
    response = @client.send_request(:put, '/notifications/mark_as.json', id: id, state: state)
    handle_response(response)
  end

  def handle_response(response)
    case response.code 
    when '200','204'
      body = response.body
      body ||= '{}'
      STDERR.puts "<#{response.body}>"
      response_json = JSON.parse(body)
    else
      STDERR.puts 'Something went wrong:'
      STDERR.puts response.message
      STDERR.puts response.code
      STDERR.puts response.body
      return JSON.parse('{}')
    end
  end

  def waiting
    response = @client.send_request(:get, '/notifications/waiting.json')
    handle_response(response)
  end

  def print_waiting
    if w = waiting
      puts w.map{|x| x.next_run}.sort
    end
  end

  def run
    @client = ApiClient::Http.new
    while true do
      response = @client.send_request(:get, '/notifications/next_to_run.json')
      case response.code 
      when '200','204'
        body = response.body
        STDERR.puts "<#{response.body}>"
        response_json = JSON.parse(body)
        id = response_json['id']
        if msg = response_json['msg']
          choice = handle_notification(msg)
          STDERR.puts "<#{choice}>"
          case choice
          when 'Done', 'Already Done', 'Skip'
            mark_as(id, choice)
          when 'Snooze'
            STDERR.puts 'We should never get "Snooze" as a choice'
          when /^\s*[0-9]+\s*[hms]?\s*$/
            snooze(id, choice)
          else
            STDERR.puts "Why is choice <#{choice}>?"
          end
        end
      else
        STDERR.puts 'Something went wrong:'
        STDERR.puts response.message
        STDERR.puts response.code.class
        STDERR.puts response.code
        STDERR.puts response.body
      end
      print_waiting
      input = gets
    end
  end
end

Scheduler.new.run
