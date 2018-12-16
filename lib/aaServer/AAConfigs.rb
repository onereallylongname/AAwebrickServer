require 'yaml'

# Class to hold AAServer configurations.
# The configurations are loaded from the Config.yml file.
# The AAConfig class is responsible for loading and validating the config file.
#
# @author Onereallylongname
# Static Class
class AAConfig
  # Class to raise invali argument error
  #
  # @author Onereallylongname
  class InvalidArgument < StandardError
    def initialize msg = 'an error was found!'
      @message = "#{msg}"
      super(msg)
    end
    def message
      @message
    end
  end
  # Class to validate an Hash given a schema
  #
  # @author Onereallylongname
  class HashValidator
    INT = :int
    INT_LIST = :intList

    def self.validate schema, toValidate
      raise InvalidArgument.new( "'toValidate' must be of type Hash. '#{toValidate}' is not of type Hash.") unless toValidate.is_a? Hash
      raise InvalidArgument.new( "'schema' must be of type Hash. '#{schema}' is not of type Hash.") unless schema.is_a? Hash

      schema.each do |k, v|
        toValidateKey = toValidate[k].nil? ? (toValidate[k.to_s].nil? ? false : k.to_s) : k
        puts toValidateKey
        if toValidateKey
          p v
          # validate_iterator k, v
        end
      end
    end

  private
    def self.validate_iterator key, val
      key.each do |k, v|
        toValidate[k]
      end
    end

  end

  # Debug level definition.
  NOLOG = nil
  DEBUG = 5
  INFO  = 4
  WARN  = 3
  ERROR = 2
  FATAL = 1
  # Content of the config file.
  @@configs = Hash.new
  # Options for the configurations.
  # The schema is used to validade and/or rebuild the Config.yml file.
  @@options = {
    configFile: 'Config.yml',
    schema: {
      'Server': {
        'RootDir': :path,
        'CertDir': :path,
        'PkeyDir': :path,
        'LoggingLevel': :debugLevel,
        'AccessLogFile': :path,
        'ServerLogFile': :path,
        'Port': HashValidator::INT,
        'MonitorInterval': HashValidator::INT,
        'ServicesPath': :pathMap
      },
      'Session': {
        'TimeToLive': HashValidator::INT,
        'MaxSessions': HashValidator::INT,
        'Masters': :ipList
      },
      'Tools':[]
      }
    }
    # Config options
    #
    # @return [Hash] the options Hash
  def self.options
    @@options
  end

  # Set Config file
  #   Define a path + name to the config file. default is "Config.yml"
  #
  # @param configPathName [String] Name of the tool
  # @return [Boolean] if file exists. If file does not exist the value is not set in the options.
  def self.config_path configPathName
    return false if !File.file?(configPathName)
    @@options[:configFile] = configPathName
    return true
  end

  # Set options
  #   Define a tool in schema
  #
  # @param toolName [String] Name of the tool
  # @return [Array] Tools Array
  def self.set_tool toolName
    raise InvalidArgument.new( "'tool' must be of type String.") unless toolName.is_a? String
    @@options[:schema][:Tools] << toolName
    @@options[:schema][:Tools]
  end

  # Get a config value
  #
  # @param key [String] Name of the tool
  # @return [Objec] value of "key"
  # @return [Hash] configs if key = nil
  def self.configs key = nil
    return @@configs unless key
    @@configs[key]
  end

  # Check if Config.yml exists
  #   the name (and path) of Config.yml can be set in the options.
  #
  # @return [Boolean] tue if file exists
  def self.config_file_exists?
    return false if !File.file?(@@options[:configFile])
  end

  # Load Configurations
  #
  # @return [Boolean] if file exists and is a valid configuration (according the schema).
  def self.load_configuration
    return false if config_file_exists?
    begin
      tempConfig = YAML.load_file(@@options[:configFile])
      # validate
      @@configs = tempConfig
      return true
    rescue => error
      puts "Configuration failed loading #{@@options[:configFile]} \n #{error}"
    end
    return false
  end

  # Get a config value
  #
  # @param toValidate [Hash] configuration Hash
  # @return [Bollean] true if Hash is valid
  def self.validate_schema toValidate
    raise InvalidArgument.new("'toValidate' must be of type Hash. '#{toValidate}' is not of type Hash.") unless toValidate.is_a? Hash

  end
end
