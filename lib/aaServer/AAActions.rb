# Ruby
=begin
  This code handles the methods used by the REST service
=end
# Code António   Almeida
require_relative 'AAJira'

class AAActions
    def initialize jiraConfigs
      @fileTypeHash = {
      'txt' => 'text/plain'.freeze, 'htm' => 'text/html'.freeze, 'html' => 'text/html'.freeze, 'css' => 'text/css'.freeze,
      'js' => 'application/javascript'.freeze, 'jsonA' => 'aplication/json'.freeze, 'json' => 'text/json'.freeze, 'geojson' => 'text/json'.freeze,
      'png' => 'image/png'.freeze, 'gif' => 'image/gif'.freeze, 'jpg' => 'image/jpeg'.freeze, 'jpeg' => 'image/jpeg'.freeze, 'ico' => 'image/x-icon'.freeze,
      'svg' => 'image/svg+xml'.freeze, 'xml' => 'text/xml'.freeze, 'csv' => 'text/csv'.freeze, 'pdf' => 'application/x-pdf'.freeze,
      'zip' => 'application/x-zip'.freeze, 'gz' => 'application/x-gzip'.freeze
    }
    @errorMessages = {'400' => 'Bad Request', '401' => 'Unauthorized', '404' => 'Not Found', '405' => 'Method Not Allowed'}
    AAJira.configs = jiraConfigs unless jiraConfigs.nil?
    end

=begin
  Private methods
  This are utils
=end
private
    def returnJsonResponse hash, code
      return JSON.generate(hash).to_s, code, @fileTypeHash['json']
    end
    def add (query)
        query['a'].to_i + query['b'].to_i
    end

    def query_contains query, list
      return (list - query.keys).empty?
    end

=begin
# Code by António Almeida
  public methods
  This mustpublish a response for the server
  [<response>, <status code>, <text type>]
  where the response must be a json
=end
public
# Test call
#
#
    def version
      return returnJsonResponse({'v' => '1.1.0', 'author' => 'António Almeida'}, 200)
    end
# Test call
#
#
    def test sessions, request, server
      return returnJsonResponse(sessions.sessions, 200)
    end
# Kick user call
#sgc573Kc59Nr--m1ShZczmhZq8OvSGMiayBg5kPqD4omEGfRr5
#
    def kick sessionsObj, request
      id = request.query['id']
      ip = request.remote_ip
      kick = request.query['kick']
      return setUnauthorized 'No Id!' unless id
      return setUnauthorized 'No Target!' unless kick
      return setUnauthorized 'Session is not valid.' unless sessionsObj.valid_session id, ip
      return setUnauthorized 'No privileges for that action.' unless sessionsObj.mastersSessions.include? ip
      sessionsObj.end_session kick
      return returnJsonResponse({'description' => 'Session cleared.', 'id' => id}, 200)
    end
# Shutdown call
#
#
    def shutdown sessionsObj, request, server
      id = request.query['id']
      ip = request.remote_ip
      return setUnauthorized 'No Id!' unless id
      return setUnauthorized 'Session is not valid.' unless sessionsObj.valid_session id, ip
      return setUnauthorized 'No privileges for that action.' unless sessionsObj.mastersSessions.include? ip
      server.shutdown
      return returnJsonResponse({'status' => 'command sent'}, 200)
    end
# Restart server
#
#
    def restart sessionsObj, request, server
    #  testResult = query_contains request.query, ['id', 'test']
    #  responseHash = {'TestResult' => testResult.to_s}
    #puts Process.pid
    # server.stop
      id = request.query['id']
      ip = request.remote_ip
      return setUnauthorized 'No Id!' unless id
      return setUnauthorized 'Session is not valid.' unless sessionsObj.valid_session id, ip
      return setUnauthorized 'No privileges for that action.' unless sessionsObj.mastersSessions.include? ip
      server.shutdown
    # windows
      system("ruby webrickServer.rb")
    #  system("""taskkill /pid #{Process.pid} /F
    #  TIMEOUT /T 3 /NOBREAK
    #  ruby webrickServer.rb""")
    # server.shutdown

      return returnJsonResponse({'status' => 'command sent'}, 200)
    end
# Get Process
#
#
    def get_pid sessionsObj, request
      id = request.query['id']
      return setUnauthorized 'No Id!' unless id
      return setUnauthorized 'Session is not valid.' unless sessionsObj.valid_session id, request.remote_ip
      process =  Process.pid
      return returnJsonResponse({'Pid' => process}, 200)
    end

# Get a session if exists
#
#
    def get_sessions sessions, request
      id = request.query['id']
      getId = request.query['getId']
      return returnJsonResponse({'error'=> '404','message' => @errorMessages['404'], 'description' => 'No Id!'}, 200) unless sessions.session_exists id
      return returnJsonResponse(sessions.sessions, 200) unless getId
      return returnJsonResponse({getId => sessions.get_session(getId)}, 200)
    end

# login to create a session
#
#
    def login sessionsObj, request
      id = request.query['id']
      return setUnauthorized 'No Id!' unless id
      return setUnauthorized 'Session already exists.' if sessionsObj.valid_session id, request.remote_ip
      return setUnauthorized 'Max sessions reached.' if sessionsObj.max_session request.remote_ip
      sessionsObj.create_session id
      sessionsObj.set_info_in_session id, 'ip', request.remote_ip
      return returnJsonResponse({'session'=> sessionsObj.sessions[id], 'id' => id}, 200)
    end

# login to jira and corfirm credentials
#
#
    def login_jira sessionsObj, request
      id = request.query['id']
      return setUnauthorized 'No Id!'unless id
      return badRequest 'Missing Information. Required fields are: id, jiraUser, jiraPass, jiraOwner' unless query_contains request.query, ['jiraUser', 'jiraPass', 'jiraOwner']
      jiraUser = request.query['jiraUser']
      jiraPass = request.query['jiraPass']
      jiraOwnerName = request.query['jiraOwner']
      # create client
      client = AAJira.login jiraUser, jiraPass, jiraOwnerName
      return badRequest AAJira.lastError if client.nil?
      if !sessionsObj.session_exists id
        sessionsObj.create_session id
        sessionsObj.set_info_in_session id, 'ip', request.remote_ip
      end
      # Add jira client to session
      sessionsObj.set_info_in_session id, 'jiraOwnerName', jiraOwnerName
      sessionsObj.set_info_in_session id, "Jira#{jiraOwnerName}", client
      return returnJsonResponse({'session'=> sessionsObj.sessions[id], 'id' => id}, 200)
    end
# Logout
#
#
    def logout sessionsObj, request
      id = request.query['id']
      return setUnauthorized 'No Id!' unless id
      return setUnauthorized 'Session does not match.' unless sessionsObj.valid_session id, request.remote_ip
      sessionsObj.end_session id
      return returnJsonResponse({'description' => 'Session cleared.', 'id' => id}, 200)
    end
# Query Jira to update the releases
#
#
    def get_release_jira sessionsObj, request
      return badRequest 'Missing Information. Required fields are: id, release.' unless query_contains request.query, ['release']
      id = request.query['id']
      return setMethodNotAllowed 'No Jira session found' unless sessionsObj.session_contaion(id, 'jiraOwnerName')
      jiraOwnerName = sessionsObj.get_info_in_session id, 'jiraOwnerName'
      client = sessionsObj.get_info_in_session id, "Jira#{jiraOwnerName}"
      release = request.query['release']
      releaseInfo = AAJira.get_query_list client, jiraOwnerName, release
      return badRequest AAJira.lastError if releaseInfo.nil?  #'Jira query failled! Please try checking if the Release value is correct.'
      sessionsObj.set_info_in_session id, "Release#{jiraOwnerName}", releaseInfo
      return returnJsonResponse({'jiraOwnerName'=> jiraOwnerName, 'release' => release, 'id' => id, 'releaseInfo' => releaseInfo}, 200)
    end
# Make text for confluence page
#
#
    def get_confluence_info_jira sessionsObj, request
      useWarn = request.query[useWarn] ? (!request.query[useWarn].upcase ==  "N") : true
      return get_some_text_jira sessionsObj, request, 'confluenceText', 'make_confluence_text', useWarn
    end
# Make text for confluence page
#
#
    def get_jira_info_jira sessionsObj, request
      useWarn = request.query[useWarn] ? (!request.query[useWarn].upcase ==  "N") : true
      return get_some_text_jira sessionsObj, request, 'jiraText', 'make_jira_text', useWarn
    end
# Make text for each release
#
#
    def get_release_info_jira sessionsObj, request
      useWarn = request.query[useWarn] ? (!request.query[useWarn].upcase ==  "N") : true
      return get_some_text_jira sessionsObj, request, 'releaseText', 'make_release_text', useWarn
    end
# Make text resolve
#
#
    def get_deliverables_info_jira sessionsObj, request
      useWarn = request.query['useWarn'].nil? ? true : (!(request.query['useWarn'].upcase ==  "N"))
      return get_some_text_jira sessionsObj, request, 'deliverablesText', 'make_deliverables_text', useWarn
    end
# Make text for confluence page
#
#
    def get_warning_info_jira sessionsObj, request
      useWarn = request.query[useWarn] ? (!request.query[useWarn].upcase ==  "N") : true
      return get_some_text_jira sessionsObj, request, 'warnText', 'make_warning_text', useWarn
    end
# generic get/make from gira, once releasequery is finished
#
#
    def get_some_text_jira sessionsObj, request, jsonKey, methodToSend, useWarn
      id = request.query['id']
      return setMethodNotAllowed 'No Jira session found' unless sessionsObj.session_contaion(id, 'jiraOwnerName')
      jiraOwnerName = sessionsObj.get_info_in_session id, 'jiraOwnerName'
      return setMethodNotAllowed 'Jira query missing, please performe the release query before.' unless sessionsObj.session_contaion(id, "Release#{jiraOwnerName}")
      releaseInfo = sessionsObj.get_info_in_session id, "Release#{jiraOwnerName}"
      text = AAJira.send(methodToSend, *[releaseInfo, jiraOwnerName, useWarn])
      return badRequest ('Something failled =( . ' + AAJira.lastError) if text.empty? and !AAJira.lastError.empty?
      return returnJsonResponse({'jiraOwnerName'=> jiraOwnerName, 'release' => releaseInfo['release'], 'id' => id, jsonKey => text, 'warning' => AAJira.lastError}, 200)
    end

=begin
  Methods to create default error responses
=end
    def badRequest description = 'Error'
      return returnJsonResponse({'error'=> '400', 'message' => @errorMessages['400'], 'description' => description }, 200)
    end

    def setUnauthorized description = 'Error'
      return returnJsonResponse({'error'=> '401', 'message' => @errorMessages['401'], 'description' => description }, 200)
    end

    def setMethodNotAllowed description = 'Error'
      return returnJsonResponse({'error'=> '405', 'message' => @errorMessages['405'], 'description' => description}, 200)
    end
end
# Code by António Almeida
