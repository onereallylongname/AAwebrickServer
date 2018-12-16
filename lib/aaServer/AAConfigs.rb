
class AAConfig
  @@debugLevels = {'DEBUG' => 5, 'INFO' => 4, 'WARN' => 3, 'ERROR' => 2, 'FATAL' => 1}
  @@options = {'configFile': 'Config.yml', 'requiredKeys': {'Server': [], 'Session', 'JIra'}}
  @@configs = Hash.new

  def self.configs key = nil
    @@configs unless key
    @@configs[key]
  end

  def self.config_file_exists?
    return false if !File.file?(@@options['configFile'])
  end

  def self.load_configuration
    return false if config_file_exists?
    begin
      @@configs = YAML.load_file((@@options['configFile'])
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
    return true
  end



end
