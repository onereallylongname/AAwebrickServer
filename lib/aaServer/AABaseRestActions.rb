require 'json'
require_relative 'AAVersion'
require_relative 'AABaseActions'

# This class handles the base methods for REST services.
# It is a static class
# The output of the methodes in this class are an Array like [<response as json>, <status code>, <text type>]
#
# @author Onereallylongname
class AABaseRestActions < AABaseActions

private
  # Return an array response for AAServer as json
  #
  # @param hash [Hash] an Hash containg the response (to be converted to json).
  # @param statusCode [Integer] an http status code to be sent in the response.
  def self.return_json_response hash, statusCode
    return JSON.generate(hash), statusCode, FileTypeHash['json']
  end

public
  # Version
  def self.version
    return return_json_response({'version' => AA::Version.version}, 200)
  end
  # Return No Content
  #
  # @param description [String] custom description.
  def self.return_no_content description = 'No Content'
    return return_json_response({'error'=> '204', 'message' => ErrorMessages['204'], 'description' => description }, 204)
  end
  # Return Bad Request
  #
  # @param description [String] custom description.
  def self.return_bad_request description = 'Error'
    return return_json_response({'error'=> '400', 'message' => ErrorMessages['400'], 'description' => description }, 400)
  end
  # Return Unauthorized
  #
  # @param description [String] custom description.
  def self.return_unauthorized description = 'Error'
    return return_json_response({'error'=> '401', 'message' => ErrorMessages['401'], 'description' => description }, 401)
  end
  # Return Method Not Allowed
  #
  # @param description [String] custom description.
  def self.return_method_not_allowed description = 'Error'
    return return_json_response({'error'=> '405', 'message' => ErrorMessages['405'], 'description' => description}, 405)
  end
end
