# Ruby
=begin
  This code handles the base methods used for the services
  # Code: António   Almeida
=end
require 'json'
require_relative 'AAVersion'

class AABaseActions
  @@fileTypeHash = {
  'txt' => 'text/plain'.freeze, 'htm' => 'text/html'.freeze, 'html' => 'text/html'.freeze, 'css' => 'text/css'.freeze,
  'js' => 'application/javascript'.freeze, 'jsonA' => 'aplication/json'.freeze, 'json' => 'text/json'.freeze, 'geojson' => 'text/json'.freeze,
  'png' => 'image/png'.freeze, 'gif' => 'image/gif'.freeze, 'jpg' => 'image/jpeg'.freeze, 'jpeg' => 'image/jpeg'.freeze, 'ico' => 'image/x-icon'.freeze,
  'svg' => 'image/svg+xml'.freeze, 'xml' => 'text/xml'.freeze, 'csv' => 'text/csv'.freeze, 'pdf' => 'application/x-pdf'.freeze,
  'zip' => 'application/x-zip'.freeze, 'gz' => 'application/x-gzip'.freeze
  }
  @@errorMessages = {'400' => 'Bad Request', '401' => 'Unauthorized', '404' => 'Not Found', '405' => 'Method Not Allowed'}

=begin
  Private methods
  This are utils
=end
private
  def self.returnJsonResponse hash, statusCode
    return JSON.generate(hash), statusCode, @@fileTypeHash['json']
  end

  def self.query_contains query, list
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
# Version
#
#
  def self.version
    return returnJsonResponse({'version' => AA::Version.version}, 200)
  end

=begin
  Methods to create default error responses
=end
    def self.badRequest description = 'Error'
      return returnJsonResponse({'error'=> '400', 'message' => @@errorMessages['400'], 'description' => description }, 200)
    end

    def self.setUnauthorized description = 'Error'
      return returnJsonResponse({'error'=> '401', 'message' => @@errorMessages['401'], 'description' => description }, 200)
    end

    def self.setMethodNotAllowed description = 'Error'
      return returnJsonResponse({'error'=> '405', 'message' => @@errorMessages['405'], 'description' => description}, 200)
    end
end
# Code by António Almeida
