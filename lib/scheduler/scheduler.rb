# lib/api-client/cli.rb

# frozen_string_literal: true

require "timeout"
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
      development: 'http://tnt:3001'
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
  @@beep_prg = 'beep'
  @@popup_prg = 'popup-choices'
  @@minimum_idle_sec            = 5   # wait until user is inactive for this long
  @@maximum_wait_sec            = 30  # wait this long before notifying although active
  @@maximum_idle_sec            = 120 # after this time we assume screen is locked
  @@wait_after_no_notifications = 60  # If there was nothing to do, sleep for a while

  def get_idle_time 
    # will differ by OS later
    # depends on get-idle-time, which I wrote
    ENV['DISPLAY']=':0'
    idle_time_ms = `get-idle-time`.chomp.to_i
    idle_time_ms = 1E6 if idle_time_ms == 0
    debug_log idle_time_ms
    return ( idle_time_ms / 1000.0 )
  end

  def wait_until_inactive(min_idle = @@minimum_idle_sec)
    # If the user has been idle too long, assume user is gone and/or
    # the screen is locked.  Do not notify during this
    while get_idle_time > @@maximum_idle_sec do
      puts 'No system activity for #{@@maximum_idle_sec} seconds'
      sleep 1
      # FIXME - maybe pop up a window with a timeout to prompt the
      # user in case they are just reading or some such
    end

    # In order to not steal the mouse or keyboard from the user while the
    # user is active, we will try to wait for the user to be "inactive"
    # (neither typing nor mousing) before allowing notification popups.
    #
    # However, if they remain active for too long, go ahead and allow
    # notifications to interrupt.
    start_time = Time.now
    while Time.now < (start_time + @@maximum_wait_sec) do
      return true if get_idle_time > min_idle
      sleep 1
    end
    return true
  end

  def debug_log(msg)
    STDERR.puts(msg)
  end

  def handle_notification(msg)
    system('beep')
    choices=['','Done', 'Already Done', 'Snooze', 'Skip', 'Pause' ]
    stdout, stderr, status = Open3.capture3(@@popup_prg, msg, *choices)
    return stdout.chomp
  end

  def pause(period)
    period.gsub!(/\s+/,'')
    case period
    when /^(\d+)h$/
      period=3600*$1.to_i
    when /^(\d+)m?$/
      period=60*$1.to_i
    when /^(\d+)s$/
      period=$1.to_i
    else
      die("Bad input - period:<#{period}>")
    end
    sleep(period)
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
      debug_log "<#{response.body}>"
      response_json = JSON.parse(body)
    else
      debug_log 'Something went wrong:'
      debug_log response.message
      debug_log response.code
      debug_log response.body
      return JSON.parse('{}')
    end
  end

  def next_runs
    response = @client.send_request(:get, '/notifications/next_runs.json')
    handle_response(response)
  end

  def waiting
    response = @client.send_request(:get, '/notifications/waiting.json')
    handle_response(response)
  end

  def print_next_runs
    if nr = next_runs
      nr.sort{|a,b| a['next_run'] <=> b['next_run']}.each{|r| pp r}
    else
      puts 'There should always be next_runs...'  
    end
  end

  def print_waiting
    if w = waiting
      puts w.map{|x| x['next_run']}.sort
    else
      false
    end
  end

  def run
    @client = ApiClient::Http.new
    active = false
    while true do
      wait_until_inactive(active ? 0 : 5)
      active = false
      print_next_runs unless print_waiting
      response = @client.send_request(:get, '/notifications/next_to_run.json')
      response_json = handle_response(response)
      id = response_json['id']
      if msg = response_json['msg']
        choice = handle_notification(msg)
        debug_log "<#{choice}>"
        case choice
        when 'Done', 'Already Done', 'Skip'
          mark_as(id, choice)
        when 'Snooze'
          debug_log 'We should never get "Snooze" as a choice'
        when /^\s*P\s*([0-9]+\s*[hms]?)\s*$/
          pause($1)
        when /^\s*[0-9]+\s*[hms]?\s*$/
          snooze(id, choice)
        else
          debug_log "Why is choice <#{choice}>?"
        end
        # We just interacted with the user, use this to skip inactivity
        # checking if there is another notification waiting to be sent.
        active = true
      else
        active = false

        sleep 10
      end
      sleep 0.1
    end
  end
end
