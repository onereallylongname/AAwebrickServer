require 'ipaddress'

# Class to hold AAServer sessions.
# A session is an entry in an Hash. It's key is an id (random Base64, 50 chars long). Valid chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-'
# The session has a 'lastUpdate' tha is used to determin if it should be cleared, and an IP.
# The session can also hold any other information needed fo the user.
#
# @author Onereallylongname
class AASession
  attr_reader :mastersSessions
  attr_accessor :sessionInactivityTime, :maxSessions
  # Initialize
  #
  # @param mastersSessions [Array] Array of the IP's with adim permissions.
  # @param logger [Logger] A ruby logger to log sessions execution.
  # @param args [HASH] options hash.
  def initialize mastersSessions, logger, args
    @logger = logger
    @sessions = Hash.new
    @mastersSessions = mastersSessions
    @sessionInactivityTime = args[:inactivityTime] || 3600 # secs
    @maxSessions = args[:maxSessions] || 10
    @idSize = args[:idSize] || 50
    @idCharSet = args[:idCharSet] || '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-'
  end

  # Create a session
  #
  # If the id does not exist a session is created withe the 'lastUpdate' equal to Time.now.
  # If the session exists the 'lastUpdate' is updated to Time.now.
  # If maximum sessions reached the session is only created if it is in the master sessions Array
  #
  # @param id [String] random Base64, 50 chars long.
  # @param ip [String] a valid client IPAddress.
  # @return [Hash] session.
  # @return [nil] if id or ip are not valid.
  def create_session id, ip
    return nil unless ((valid_id id) and (valid_ip ip))
    return nil if max_sessions? and !@mastersSessions.include? ip
    @sessions[id] = {'lastUpdate' => Time.now}
    @sessions[id] = {'ip' => ip}
    @logger.info("Session created: #{id}")
    @sessions[id]
  end

  # Update a session
  #
  # If the id does not exist a session is created withe the 'lastUpdate' equal to Time.now.
  # If the session exists the 'lastUpdate' is updated to Time.now.
  #
  # @param id [String] random Base64, 50 chars long.
  def updated_sessoin id
    return nil unless session_exists? id
    @sessions[id]['lastUpdate'] = Time.now
    @sessions[id]
  end

  # Max sessions
  #
  # Check if maximum number of sessions was reached.
  # Logs max session if max sessions was reached.
  #
  # @return [Boolean]
  def max_sessions?
    @logger.warn("Max sessions reached: #{@maxSessions}") if @sessions.keys.size >= @maxSessions
    @sessions.keys.size >= @maxSessions
  end

  # Set info in session
  #
  # Save information to a session.
  #
  # @param id [String] valid id
  # @param key [String] hash key, name of information
  # @param val [Object] ruby object
  # @return [nil] if id is not valid
  def set_info_in_session id, key, val
    return nil unless session_exists? id
    @sessions[id][key] = val
  end

  # Get sessions
  #
  # @return [nil] if session does not exist
  # @return [Hash] session hash
  def get_session id
    @sessions[id]
  end

  # Get session info
  #
  # Get value from session stored info
  #
  # @param id [String] valid id
  # @param key [String] hash key, name of information
  # @return [nil] if info (key) does not exist
  # @return [Hash] info object
  def get_info_in_session id, key
    @sessions[id][key]
  end

  # End a session
  #
  # The session is removed from the sessions hash.
  #
  # @param id [String] valid id
  def end_session id
    @sessions.delete id
  end

  # Valid val in session
  #
  # Test if some info in a session is equal to an Object.
  #
  # @param id [String] valid id
  # @param key [String] hash key, name of information
  # @param val [Object] object to test
  # @return [Boolean]
  def valid_val_in_session id, key, val
    return false unless sessions[id][key]
    sessions[id][key] == val
  end

  # Valid session
  #
  # Test if an id and ip correspond to a valid session.
  #
  # @param id [String] valid id
  # @param ip [String] session ip
  # @return [Boolean]
  def valid_session? id, ip
    return false unless session_exists? id
    valid_val_in_session id, 'ip', ip
  end

  # Admin rights
  #
  # Test if an id and ip correspond to a valid session.
  #
  # @param id [String] valid id
  # @param ip [String] session ip
  # @return [Boolean]
  def admin_rights? ip
    return @mastersSessions.include? id
  end
  # Get id from ip
  #
  # Get id given an ip.
  #
  # @param ip [String] session ip
  # @return [Array] of ids with that ip
  def get_id_from_ip ip
    @sessions.select{|k,v| v['ip'] == ip}.keys
  end

  # Session contains
  #
  # Test if a session contains a key.
  #
  # @param id [String] session ip
  # @param key [String]
  # @return [Boolean]
  def session_contains id, key
    return false unless session_exists? id
    @sessions[id].key?(key)
  end

  # Session exists
  #
  # Test if a session exists.
  #
  # @param id [String] session ip
  # @return [Boolean]
  def session_exists? id
    @sessions.key?(id)
  end

  # Cleanup
  #
  # Clean expired sessions.
  # Check every session's 'lastUpdate', if it is older than 'sessionInactivityTime' delete session.
  # If sessions were deleted log deleted sessions.
  def cleanup
#      puts ''
#      puts @sessionInactivityTime
#      @sessions.each{|k,v| puts k; puts v['lastUpdate'].class; puts (Time.now - v['lastUpdate']).to_i; puts (Time.now - v['lastUpdate']).to_i > @sessionInactivityTime}
    originalKeys = @sessions.keys
    @sessions.delete_if { |k,v| (Time.now - v['lastUpdate']).to_i > @sessionInactivityTime}
    removedKeys = originalKeys - @sessions.keys
    @logger.info("Sessions cleaned: #{removedKeys}") unless removedKeys.empty?
  end

private
  # Valid id
  #
  # Test if an id is valid.
  #
  # @param id [String] session ip
  # @return [Boolean]
  def valid_id id
    return false unless id.is_a? String
    return false unless id.size == @idSize
    unwanted = id.delete @idCharSet
    unwanted.empty?
  end
  # Valid ip
  #
  # Test if an ip is valid.
  #
  # @param ip [String] session ip
  # @return [Boolean]
  def valid_ip ip
    return false unless ip.is_a? String
    IPAddress.valid?(ip)
  end

end
# Code by António Almeida
