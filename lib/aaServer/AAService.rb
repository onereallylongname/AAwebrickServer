require_relative 'AAConfigs'
require_relative 'AAActions'

# Class AAService, wrapper for HTTPServlet::AbstractServlet.
#
# @author Onereallylongname
class AAService < WEBrick::HTTPServlet::AbstractServlet

  # Initialize AAService
  #
  # @param server [WEBrick::HTTPServer]
  # @param sessions [AASession]
  def initialize server, sessions, path
    super(server)
    @server = server
    @path = path
    @pathSize = path.size
    @sessions = sessions
  end

  # Overwrite service
  #
  # Validate sessios, and call method "do_".
  #
  # @param query [WEBrick::HTTPRequest]
  # @param query [WEBrick::HTTPResponse]
  def service (request, response)

    p request.path
    p request.script_name

    method_name = "do_" << (request.path[(@pathSize + 1)..-1]).gsub(/\//,'_')
    p method_name
    #method_name = "do_" + request.request_method.gsub(/-/, "_")
    if respond_to?(method_name)
      infoHash = {request: request, response: response, sessions: sessions}
      set_array_to_response response, __send__(method_name, infoHash)
    else
      responde_with_error request, response
    end
    p response.body
  end

private

  # GET service
  #
  # @param query [WEBrick::HTTPRequest]
  # @param query [WEBrick::HTTPResponse]
  def do_GET (infoHash)
    return ["done \n", 200, 'text/plain']
  end

  # POST service
  #
  # @param query [WEBrick::HTTPRequest]
  # @param query [WEBrick::HTTPResponse]
  def do_POST (infoHash)
    return ["done \n", 200, 'text/plain']
  end

  def valid_session? request
    return false unless request.query['id']
    return false unless @sessions.valid_session? request.query['id'], request.remote_ip
  end

  def admin_rights? request
    return false unless valid_session? request
    @sessions.admin_rights? request.remote_ip
  end

  def responde_with_error request, response
    raise WEBrick::HTTPStatus::MethodNotAllowed,
           "Unsupported Method `#{request.request_method} for #{request.path}'."
  end

  def set_array_to_response response, array
    response.body = array[0]
    response.status = array[1]
    response.content_type = array[2]
  end
end
# Code by António Almeida
