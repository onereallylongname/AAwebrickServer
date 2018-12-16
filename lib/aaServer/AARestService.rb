# Ruby
=begin
  This code handles actions taken by the REST service
=end
# Codeby AntónioAlmeida
require_relative 'AASession'
require_relative 'AAActions'

class AARestService < WEBrick::HTTPServlet::AbstractServlet

  def initialize args, restPath, sessionObj, jiraConfigs
    super(args)
    @restPath = restPath
    @actions = AAActions.new jiraConfigs
    @sessions = sessionObj
    @sessions.cleanup_cicle
  end

# Action Get
#
#
  def do_GET (request, response)
  #  p "#{Time.now} - #{request.remote_ip} - #{request.path} - id=#{request.query['id']}"
    @logger.info("#{request.remote_ip} - #{request.path}")
=begin
puts ''
puts "DEBUG-----------------------"
    pp request.path
    pp request.query
puts "-----------------------DEBUG"
puts''
=end
    result = ''
    statusCode = 200
    contentType = "text/plain"
    if @sessions.valid_session request.query['id'], request.remote_ip
      result, statusCode, contentType = handle_valid_session_get @sessions, request
    elsif @sessions.session_exists request.query['id']
      result, statusCode, contentType = handle_existing_session_get @sessions, request
    else
      result, statusCode, contentType = handle_non_existing_session_get @sessions, request
    end
    response.body = result.to_s  + "\n"
    response.status = statusCode
    response.content_type = contentType
    return response
  end

# Action POST
#
#
  def do_POST (request, response)
    pp request
    response.body = "{\"status\":\"Done\"}"
    response.status = "200"
    response.content_type = "text/plain"
  end
# Action to take if there is a valid session (id and ip match the session)
#
#
  def handle_valid_session_get session, request
    sessionId = @sessions.set_sessoin request.query['id']
    case request.path
      when @restPath + '/test'
          result, statusCode, contentType = @actions.test session, request, @server
      when @restPath + '/get/pid'
          result, statusCode, contentType = @actions.get_pid session, request
      when @restPath + '/restart'
          result, statusCode, contentType = @actions.restart session, request, @server
      when @restPath + '/sessions/get'
          result, statusCode, contentType = @actions.get_sessions @sessions, request
      when @restPath + '/jira/get/release'
          result, statusCode, contentType = @actions.get_release_jira @sessions, request
      when @restPath + '/jira/get/info/confluence'
          result, statusCode, contentType = @actions.get_confluence_info_jira @sessions, request
      when @restPath + '/jira/get/info/jira'
          result, statusCode, contentType = @actions.get_jira_info_jira @sessions, request
      when @restPath + '/jira/get/info/release'
          result, statusCode, contentType = @actions.get_release_info_jira @sessions, request
      when @restPath + '/jira/get/info/deliverables'
          result, statusCode, contentType = @actions.get_deliverables_info_jira @sessions, request
      when @restPath + '/jira/get/info/warning'
          result, statusCode, contentType = @actions.get_warning_info_jira @sessions, request
      when @restPath + '/logout'
          result, statusCode, contentType = @actions.logout @sessions, request
      when @restPath + '/shutdown'
          result, statusCode, contentType = @actions.shutdown @sessions, request, @server
      when @restPath + '/kick'
          result, statusCode, contentType = @actions.kick @sessions, request
      when @restPath + '/version'
          result, statusCode, contentType = @actions.version @sessions, request
      else
          result, statusCode, contentType = @actions.setUnauthorized "This method was not found."
    end
  end

# Action to take if there is an id
#
#
  def handle_existing_session_get session, request
    sessionId = @sessions.set_sessoin request.query['id']
    case request.path
      when @restPath + '/test'
          result, statusCode, contentType = @actions.test session, request, @server
      when @restPath + '/version'
          result, statusCode, contentType = @actions.version
      else
          result, statusCode, contentType = @actions.setUnauthorized "This method or session was not found. Try login."
    end
  end

# Action to take if there is no id
#
#
  def handle_non_existing_session_get session, request
    case request.path
      when @restPath + '/test'
          result, statusCode, contentType = @actions.test session, request, @server
      when @restPath + '/login'
          result, statusCode, contentType = @actions.login @sessions, request
      when @restPath + '/jira/login'
          result, statusCode, contentType = @actions.login_jira @sessions, request
      when @restPath + '/version'
          result, statusCode, contentType = @actions.version
      else
          result, statusCode, contentType = @actions.setMethodNotAllowed "This metho does not exist. Try login first."
    end
  end

end
# Code by António Almeida
