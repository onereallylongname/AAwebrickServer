# Ruby
=begin
  This code handles the methods used by the REST service
=end
# Code António   Almeida
require_relative 'AAJira'

class AAJiraActions < AABaseActions
  def self.init jiraConfigs
    AAJira.configs = jiraConfigs unless jiraConfigs.nil?
  end
# login to jira and corfirm credentials
#
#
  def self.login_jira sessionsObj, request
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
# Query Jira to update the releases
#
#
  def self.get_release_jira sessionsObj, request
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
  def self.get_confluence_info_jira sessionsObj, request
    useWarn = request.query[useWarn] ? (!request.query[useWarn].upcase ==  "N") : true
    return get_some_text_jira sessionsObj, request, 'confluenceText', 'make_confluence_text', useWarn
  end
# Make text for confluence page
#
#
  def self.get_jira_info_jira sessionsObj, request
    useWarn = request.query[useWarn] ? (!request.query[useWarn].upcase ==  "N") : true
    return get_some_text_jira sessionsObj, request, 'jiraText', 'make_jira_text', useWarn
  end
# Make text for each release
#
#
  def self.get_release_info_jira sessionsObj, request
    useWarn = request.query[useWarn] ? (!request.query[useWarn].upcase ==  "N") : true
    return get_some_text_jira sessionsObj, request, 'releaseText', 'make_release_text', useWarn
  end
# Make text resolve
#
#
  def self.get_deliverables_info_jira sessionsObj, request
    useWarn = request.query['useWarn'].nil? ? true : (!(request.query['useWarn'].upcase ==  "N"))
    return get_some_text_jira sessionsObj, request, 'deliverablesText', 'make_deliverables_text', useWarn
  end
# Make text for confluence page
#
#
  def self.get_warning_info_jira sessionsObj, request
    useWarn = request.query[useWarn] ? (!request.query[useWarn].upcase ==  "N") : true
    return get_some_text_jira sessionsObj, request, 'warnText', 'make_warning_text', useWarn
  end
# generic get/make from gira, once releasequery is finished
#
#
  def self.get_some_text_jira sessionsObj, request, jsonKey, methodToSend, useWarn
    id = request.query['id']
    return setMethodNotAllowed 'No Jira session found' unless sessionsObj.session_contaion(id, 'jiraOwnerName')
    jiraOwnerName = sessionsObj.get_info_in_session id, 'jiraOwnerName'
    return setMethodNotAllowed 'Jira query missing, please performe the release query before.' unless sessionsObj.session_contaion(id, "Release#{jiraOwnerName}")
    releaseInfo = sessionsObj.get_info_in_session id, "Release#{jiraOwnerName}"
    text = AAJira.send(methodToSend, *[releaseInfo, jiraOwnerName, useWarn])
    return badRequest ('Something failled =( . ' + AAJira.lastError) if text.empty? and !AAJira.lastError.empty?
    return returnJsonResponse({'jiraOwnerName'=> jiraOwnerName, 'release' => releaseInfo['release'], 'id' => id, jsonKey => text, 'warning' => AAJira.lastError}, 200)
  end
end
# Code by António Almeida
