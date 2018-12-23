require 'yaml'
require 'ipaddress'

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
  # Class to raise invali argument error
  #
  # @author Onereallylongname
  class InvalidConfigurationFile < StandardError
    def initialize msg = ''
      @message = "Configuration file does not respect schema.\n#{msg}"
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

    def self.validate schema, toValidate
      raise InvalidArgument.new( "'toValidate' must be of type Hash. '#{toValidate}' is not of type Hash.") unless toValidate.is_a? Hash
      raise InvalidArgument.new( "'schema' must be of type Hash. '#{schema}' is not of type Hash.") unless schema.is_a? Hash

      validate_iterator schema, toValidate
    end

  private
    def self.validate_iterator schemaVal, toValidate

      failingKeys = {}
      schemaVal.each do |k, v|
        toValidateKey = toValidate[k].nil? ? (toValidate[k.to_s].nil? ? nil : k.to_s) : k
        # p k
        # p v
        # p toValidate[toValidateKey]
        return {k => 'nil'} if toValidate[toValidateKey].nil?
        if v.is_a? Symbol or v.is_a? String
          required = v[-1] == 'R'
          if required
            if toValidateKey.nil?
              failingKeys[k] = 'nil'
            else
              failingKeys[k] = "'#{toValidate[toValidateKey]}' is not a valid '#{v[0..-2]}'" unless valid_type? v[0..-2], toValidate[toValidateKey]
            end
          end
        elsif v.is_a? Hash
          tempfailingKeys = validate_iterator v, toValidate[toValidateKey]
          failingKeys[k] = tempfailingKeys unless tempfailingKeys.empty?
        end
      end

      return failingKeys
    end

    def self.valid_type? type, val
      tp = type.to_s
      case tp
      when 'int'
        return val.is_a? Integer
      when 'str'
        return val.is_a? String
      when 'array'
        return val.is_a? Array
      when 'map'
        return val.is_a? Hash
      when 'file'
        return false unless val.is_a? String
        return File.file?(val)
      when 'path'
        return false unless val.is_a? String
        return File.directory?(val)
      when 'ip'
        return false unless val.is_a? String
        return IPAddress.valid?(val)
      when 'debugLevel'
        return false unless val.is_a? String
        return !(AAConfig::DEBUG_LEVELS)[val].nil?
      end
      return false
    end
  end

  # Debug level definition.
  DEBUG_LEVELS = {
          'NOLOG' => nil,
          'DEBUG' => 5,
          'INFO'  => 4,
          'WARN'  => 3,
          'ERROR' => 2,
          'FATAL' => 1
        }
  # Content of the config file.
  @@configs = Hash.new
  # Options for the configurations.
  # The schema is used to validade and/or rebuild the Config.yml file.
  @@options = {
    configFile: 'Config.yml',
    schema: {
      'Server' => {
        'RootDir' => :pathR,
        'CertDir' => :fileR,
        'PkeyDir' => :fileR,
        'LoggingLevel' => :debugLevelR,
        'AccessLogFile' => :fileR,
        'ServerLogFile' => :fileR,
        'Port' => :intR,
        'MonitorInterval' => :intR,
        'ServicesPath' => :mapR
      },
      'Session' => {
        'TimeToLive' => :intR,
        'MaxSessions' => :intR,
        'LogFile' => :fileR,
        'Masters'=> :array_
      },
      'Tools'=> :mapR
      },
    'Tools'=> []
    }
    # Config options
    #
    # @return [Hash] the options Hash
  def self.options
    @@options
  end

  # Set Config file
  #
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
  #
  #   Define a tool in schema
  #
  # @param toolName [String] Name of the tool
  # @return [Array] Tools Array
  def self.set_tool toolName
    raise InvalidArgument.new( "'tool' must be of type String.") unless toolName.is_a? String
    @@options[:Tools] << toolName
    @@options[:Tools]
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
  #
  #   The name (and path) of Config.yml can be set in the options.
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
      errors = AAConfig::HashValidator.validate( AAConfig.options[:schema], tempConfig)
      raise InvalidConfigurationFile.new(errors.to_s) unless errors.empty?
      @@configs = tempConfig
      return true
    rescue => error
      puts "Configuration failed loading #{@@options[:configFile]} \n #{error}"
    end
    return false
  end

  # Load Configurations
  #
  # @return [Boolean] if file exists and is a valid configuration (according the schema).
  def self.load_schema path
    return false if !File.file?(path)
    begin
      @@options[:schema] = YAML.load_file(path)
      return true
    rescue => error
      puts "Schema failed loading #{path}."
    end
    return false
  end

  # Create Configurations (as YAML)
  #
  # @return [YAML]
  def self.create_configs
    textYaml = '''# ---- ReleaseManagerHelper configuration File ---- #
# To apply changes made to the config file please restart the server.
# Server configurations
# Replace :type_ by a values: where :type is the variable type and last cahr equal to R means that is a required field
'''
    textYaml += @@options[:schema].to_yaml.to_s
    textYaml
  end

  # Get a config value
  #
  # @return [Bollean] true if Hash is valid
  def self.validate_schema
    AAConfig::HashValidator.validate( AAConfig.options[:schema], AAConfig.configs)
  end
end
