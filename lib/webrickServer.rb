#!/usr/bin/env ruby
# https://gist.github.com/Integralist/2862917
# https://docs.ruby-lang.org/en/2.1.0/WEBrick.html
# Code by António Almeida
require "webrick"
require 'webrick/https'
require 'openssl'
require 'json'
require 'yaml'
require 'jira-ruby'
require_relative 'ServerLib/server_launch'

@debugLevels = {'DEBUG' => WEBrick::Log::DEBUG, 'INFO' => WEBrick::Log::INFO, 'WARN' => WEBrick::Log::WARN, 'ERROR' => WEBrick::Log::ERROR, 'FATAL' => WEBrick::Log::FATAL}

def load_configuration_
  return false if !File.file?('Config.yml')
  begin
    config = YAML.load_file('Config.yml')
#    @showInfo = config['ReleaseManagerHelper']['Server']['DebugImportanceLevel']
    @serverRoot = config['Server']['RootDir']
    @serverPort = config['Server']['Port']
    @CertDir = config['Server']['CertDir']
    @PkeyDir = config['Server']['PkeyDir']
    @debugLevel = config['Server']['LoggingLevel']
    @logFile = config['Server']['LogFile']
    @logAccessLogFile = config['Server']['AccessLogFile']
    @restPath = config['Server']['RestPath']
    @sessionTime = config['Session']['TimeToLive']
    @sessionsLogDir = config['Session']['LogFile']
    @mastersSessions = config['Session']['Masters']
    @maxSessions = config['Session']['MaxSessions']
    @cleanupWaitTime = config['Session']['TimeOfinactivity']
    @jiraConfig = config['Jira']
#    @secureConnection = config['ReleaseManagerHelper']['Server']['UseSSL']
    return true
  rescue => error
    puts "Configuration failed loading 'Config.yml' \n #{error}"
  end
  return false
end

load_configuration_

#Set defaul values if any is missing
@serverRoot ||= './ServerRoot'
@serverPort ||= 1234
@CertDir ||= './Cert/cert.pem'
@PkeyDir ||= './Cert/pkey.pem'
@sessionTime ||= 7200
@cleanupWaitTime ||= 60
@sessionsLogDir ||= './Log/Sessions.log'
@restPath ||= '/services/rest'
@debugLevel ||= 'WARN'
@logFile ||= './Log/webrickServer.log'
@logAccessLogFile ||= './Log/webrickServerAccess.log'
@maxSessions ||= 10

sessionsLog = WEBrick::Log.new @sessionsLogDir, @debugLevels[@debugLevel]

@sessionObj = AASessions.new @mastersSessions, sessionsLog
@sessionObj.sessionInactivityTime = @sessionTime
@sessionObj.cleanupWaitTime = @cleanupWaitTime
@sessionObj.maxSessions = @maxSessions

root = File.expand_path @serverRoot
cert = OpenSSL::X509::Certificate.new File.read @CertDir
pkey = OpenSSL::PKey::RSA.new File.read @PkeyDir

log = WEBrick::Log.new STDOUT, @debugLevels[@debugLevel] # WEBrick::Log.new @logFile, @debugLevels[@debugLevel]

server = WEBrick::HTTPServer.new(:Port => @serverPort,
                                 :SSLEnable => true,
                                 :SSLCertificate => cert,
                                 :SSLPrivateKey => pkey,
                                 :Logger => log,
                                 :AccessLog => [[File.open(@logAccessLogFile,'a+'),"%t - %T - %h %p - %m %U"]],
                                 :DocumentRoot => @serverRoot)

# server = WEBrick::HTTPServer.new(:Port => port)

server.mount @restPath, AARestService, @restPath, @sessionObj, @jiraConfig
#server.mount "/", WEBrick::HTTPServlet::FileHandler, './'
# Codeby AntónioAlmeida

trap("INT") {
    server.shutdown
}
puts 'Server start'
puts "logs at : ./Log"
begin
  server.start
ensure
  server.shutdown
end

# Codeby AntónioAlmeida

=begin
    WEBrick is a Ruby library that makes it easy to build an HTTP server with Ruby.
    It comes with most installations of Ruby by default (it’s part of the standard library),
    so you can usually create a basic web/HTTP server with only several lines of code.

    The following code creates a generic WEBrick server on the local machine on port 1234,
    shuts the server down if the process is interrupted (often done with Ctrl+C).
    Example usage:
        http://localhost:1234/ (this will show the specified error message)
=end
