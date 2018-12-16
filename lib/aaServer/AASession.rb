# Ruby
=begin
  This code handles sessions inside the server
=end
# Code by António Almeida
class AASessions
  attr_reader :sessions, :mastersSessions
  attr_accessor :sessionInactivityTime, :maxSessions, :cleanupWaitTime
  def initialize mastersSessions, logger
    @logger = logger
    @sessions = Hash.new
    @cleanGo = true
    @mastersSessions = mastersSessions
    @sessionInactivityTime = 3600 # secs
    @cleanupWaitTime = 60 # sec
    @maxSessions = 10
  end

  def create_session id
      @sessions[id] = {'lastUpdate' => Time.now}
  end

  def max_session ip
    @logger.warn("Max sessions reached: #{@maxSessions}") if @sessions.keys.size >= @maxSessions
    return false if ((@mastersSessions.include? ip) and ((get_id_from_ip ip).empty?))
    @sessions.keys.size >= @maxSessions
  end

  def set_sessoin id
    @sessions[id]['lastUpdate'] = Time.now
    @sessions[id]
  end

  def set_info_in_session id, key, val
    @sessions[id][key] = val
  end

  def get_session id
    @sessions[id]
  end

  def get_info_in_session id, key
    @sessions[id][key]
  end

  def end_session id
    @sessions.delete id
  end

  def valid_val_in_session id, key, val
    return false unless sessions[id][key]
    sessions[id][key] == val
  end

  def valid_session id, ip
    return false unless session_exists id
    valid_val_in_session id, 'ip', ip
  end

  def get_id_from_ip ip
    @sessions.select{|k,v| v['ip'] == ip}.keys
  end

  def session_contaion id, key
    return false unless session_exists id
    @sessions[id].key?(key)
  end

  def session_exists id
    @sessions.key?(id)
  end

  def cleanup_cicle
    Thread.new do
      while @cleanGo
#        puts ''
#        puts @sessionInactivityTime
#        @sessions.each{|k,v| puts k; puts v['lastUpdate'].class; puts (Time.now - v['lastUpdate']).to_i; puts (Time.now - v['lastUpdate']).to_i > @sessionInactivityTime}
        originalSize = @sessions.keys.size
        @sessions.delete_if { |k,v| (Time.now - v['lastUpdate']).to_i > @sessionInactivityTime}
        @logger.info("Cleanup. session remaining: #{@sessions}") if originalSize != @sessions.keys.size
        sleep @cleanupWaitTime
      end
    end
  end
end
# Code by António Almeida
