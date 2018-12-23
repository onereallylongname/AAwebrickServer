
require 'json'
require_relative 'AAVersion'

# This class handles the base methods for all services.
# It is a static class.
#
# @author Onereallylongname
class AABaseActions
  FileTypeHash = {
  'txt' => 'text/plain'.freeze, 'htm' => 'text/html'.freeze, 'html' => 'text/html'.freeze, 'css' => 'text/css'.freeze,
  'js' => 'application/javascript'.freeze, 'jsonA' => 'aplication/json'.freeze, 'json' => 'text/json'.freeze, 'geojson' => 'text/json'.freeze,
  'png' => 'image/png'.freeze, 'gif' => 'image/gif'.freeze, 'jpg' => 'image/jpeg'.freeze, 'jpeg' => 'image/jpeg'.freeze, 'ico' => 'image/x-icon'.freeze,
  'svg' => 'image/svg+xml'.freeze, 'xml' => 'text/xml'.freeze, 'csv' => 'text/csv'.freeze, 'pdf' => 'application/x-pdf'.freeze,
  'zip' => 'application/x-zip'.freeze, 'gz' => 'application/x-gzip'.freeze
  }
  ErrorMessages = {'204' => 'No Content', '400' => 'Bad Request', '401' => 'Unauthorized', '404' => 'Not Found', '405' => 'Method Not Allowed'}

private
  # Check if the query contais a param
  #
  # @param query [Hash] WEBrick::HTTPRequest.query
  # @param list [Array] List of keys to look for in query
  def self.query_contains? query, list
    return (list - query.keys).empty?
  end

public

end
