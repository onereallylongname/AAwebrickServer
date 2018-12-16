# Ruby
=begin
  This code handles the Jira methods used by the REST service
=end
# Code by António Almeida
require 'jira-ruby'

class AAJira
  @@lastError = ''
# Defaul configs
  @@configs = {"Celfocus"=>
                {"Site"=>"https://celfocusjira.atlassian.net:443",
                 "ProjectName"=>"VFGBNOCCIA",
                 "Component"=>"Automation",
                 "QueryFields"=>
                  {"status"=>"status",
                   "installationNotes"=>"customfield_10066",
                   "summary"=>"summary",
                   "issuetype"=>"issuetype",
                   "assignee"=>"assignee"},
                  "NewLineChar" => '\n',
                  'DeployStatus' => [
                      'Resolved',
                      'Ready For Deploy'
                    ],
                   "Deliverables" => [
                     'Runbooks',
                     'Action Tasks',
                     'Properties',
                     'Gateway Filters',
                     'Job Schedulers',
                     'DB Scripts',
                     'Gateway Filters'
                   ],
                   "ResolveDeliverables" =>[
                     'Runbooks',
                     'Action Tasks',
                     'Properties',
                   ]
                },
               "Vodafone"=>
                {"Site"=>"https://cias.jira.agile.vodafone.com:443",
                  "ProjectName"=>"CIAS"
                }
              }
# Set configurations
#
  def self.configs= (conf)
    @@configs = conf
  end
# Get configurations
#
  def self.configs
    @@configs
  end
# Read lastError
#
    def self.lastError
      lastError = @@lastError
      @@lastError = ''
      lastError
    end

# login to jira and corfirm credentials
#
  def self.login(jiraUser, jiraPass, jiraOwner)
    if @@configs[jiraOwner].nil?
      @@lastError = "Invalid jiraOwner."
      return nil
    end
    projectName = @@configs[jiraOwner]['ProjectName']
    # create Jira client options
    options = {
      :username => jiraUser,
      :password => jiraPass,
      :site         => @@configs[jiraOwner]['Site'],
      :context_path => '',
      :auth_type    => :basic
    }
    # create Jira client and test user
    client = JIRA::Client.new(options)
    begin
      #test connection and credentials
      test = client.Issue.jql("key = #{projectName}-1", fields:[:summary])
    rescue => e
      # Debug
    #  p e.response.header

      @@lastError =  "Unable to connect to Jira. Jira header: #{e.response.header} Jira Body#{e.response.body}"
    return nil
    end
    return client
  end

# Query jira for release objects
#
  def self.get_query_list client, jiraOwnerName, fixVersion
    queryVals = @@configs[jiraOwnerName]['QueryFields']
    fields = [] # [status, installationNotes, summary, issuetype, assignee]
    fields << queryVals['status'].to_sym  #status
    fields << queryVals['installationNotes']['Value'].to_sym #installationNotes
    fields << queryVals['summary'].to_sym #summary
    fields << queryVals['issuetype'].to_sym # issuetype
    fields << queryVals['assignee'].to_sym # assignee
    component = @@configs[jiraOwnerName]['Component'].to_sym
    site = @@configs[jiraOwnerName]['Site']
    list = []
    begin
      list = client.Issue.jql("fixVersion = #{fixVersion} and component = #{component}", fields: fields)
    rescue => e
      # Debug
    #  p e.response.header

      @@lastError =  "Unable to connect to Jira. Jira header: #{e.response.header} Jira Body#{e.response.body}"
    return nil
    end
    jiraHash = Hash.new
    list.each do |issue|
    installationNotes = nil
      begin
        thing1 = YAML.load(issue.fields[queryVals['installationNotes']['Value']])
        installationNotes = thing1[fixVersion]
      rescue
        installationNotes = {'Type' => '', 'error' => 'YAML failed! Unable to parse Installation Notes.'}
      end
      jiraHash[issue.key] = {queryVals['assignee'] => issue.fields[queryVals['assignee']]['name'], queryVals['summary']=> issue.fields[queryVals['summary']], queryVals['issuetype']=> issue.fields[queryVals['issuetype']]['name'], queryVals['status'] => issue.fields[queryVals['status']]['name'], 'url' => site+'/browse/'+issue.key, 'installationNotes' => installationNotes}
    end
    jiraFinalHash = {'release' => fixVersion, 'list' => jiraHash}
    jiraFinalHash
  end

# Make confluence text
#
    def self.make_confluence_text releaseList, jiraOwnerName, useWarn
      nlc = @@configs[jiraOwnerName]['NewLineChar'] ? @@configs[jiraOwnerName]['NewLineChar'] : '\n'
      warnings = {'keys' => []}
      warnings = make_warning_text releaseList, jiraOwnerName, useWarn if useWarn
      text = ""
      releaseFeatures = '' # "#{nlc}Release Features#{nlc}#{nlc}"
      enhancements = '' # "#{nlc}Enhancements#{nlc}#{nlc}"
      fixes = '' # "#{nlc}Fixes#{nlc}#{nlc}"
      problems = '' # "#{nlc}Known Issues and Problems#{nlc}#{nlc}"
      upgrades = '' # "#{nlc}Technical Upgrades#{nlc}#{nlc}"
      installationInformation = '' # "#{nlc}Installation Information#{nlc}#{nlc}"
      tempLastError = ''
      releaseList['list'].each do |k,v|
        if warnings['keys'].include?(k) and useWarn
          tempLastError += "#{k}#{nlc}"
          next
        end
        type = v['installationNotes']['Type']
        if(type)
          case type
          when 'Release Features'
            releaseFeatures += "#{k} #{v['summary']}#{nlc}"
          when 'Enhancements'
            enhancements += "#{k} #{v['summary']}#{nlc}"
          when 'Fixes'
            fixes += "#{k} #{v['summary']}#{nlc}"
          else
            tempLastError += "#{k}#{nlc}"
          end
          inst = v['installationNotes']['Instructions']
          inst.each{ |i|  installationInformation += "#{i}#{nlc}"} if inst
          prob = v['installationNotes']['Problems']
          prob.each { |i|  problems += "#{i}#{nlc}"} if prob
          upda = v['installationNotes']['Upgrades']
          upda.each { |i|  upgrades += "#{i}#{nlc}"} if upda
        else
          tempLastError += "#{k}#{nlc}"
        end
      end
      @@lastError = !tempLastError.empty? ? tempLastError : @@lastError
      text = {'Release Features' => releaseFeatures, 'Enhancements' => enhancements, 'Fixes' => fixes, 'Known Issues and Problems' => problems, 'Technical Upgrades' => upgrades, 'Installation Information' => installationInformation}
    end
# Make release jira text
#
    def self.make_jira_text releaseList, jiraOwnerName, useWarn
      nlc = @@configs[jiraOwnerName]['NewLineChar'] ? @@configs[jiraOwnerName]['NewLineChar'] : '\n'
      warnings = {'keys' => []}
      warnings = make_warning_text releaseList, jiraOwnerName, useWarn if useWarn
      hashText = Hash.new
      text = "#{nlc}#{nlc}Jiras delivered:#{nlc}"
      tempLastError = ''
      releaseList['list'].each do |k, v|
        if warnings['keys'].include?(k) and useWarn
          tempLastError += "#{k}#{nlc}"
          next
        end
          text += "#{k}#{nlc}"
      end
      @@lastError = !tempLastError.empty? ? tempLastError : @@lastError
      key = "Release #{releaseList['release']}:"
      hashText[key] = text
      return hashText
    end
# Make release text
#
    def self.make_release_text releaseList, jiraOwnerName, useWarn
      return releaseList
    end
# Make resolve text
#
    def self.make_deliverables_text releaseList, jiraOwnerName, useWarn
      warnings = {'keys' => []}
      warnings = make_warning_text releaseList, jiraOwnerName, useWarn if useWarn
      text = Hash.new
      text['Warnings'] = Hash.new
      jiraKeys = []
      releaseList['list'].each do |k,v|
        jiraKeys << k
        next if warnings['keys'].include? k and useWarn
        v['installationNotes'].each do |field, list|
          if @@configs[jiraOwnerName]['Deliverables'].include? field
            text[field] = {'artifacts' => [], 'issueKeys' => []} if text[field].nil?
            if list.kind_of?(Array)
              list.each do |obj|
                if !text[field]['artifacts'].include? obj
                  text[field]['artifacts'] << obj
                  text[field]['issueKeys'] << k
                end
              end
            elsif list.kind_of?(Hash)
              list.flatten.each do |obj|
                if !text[field]['artifacts'].include? obj
                  text[field]['artifacts'] << obj
                  text[field]['issueKeys'] << k
                end
              end
            else
              list.to_s.flatten.each do |obj|
                if !text[field]['artifacts'].include? obj
                  text[field]['artifacts'] << obj
                  text[field]['issueKeys'] << k
                end
              end
            end
          end
        end
      end
      emptyText = (jiraKeys == warnings['keys'])
      #text.each{|k,v| text[k] = v.uniq; emptyText = emptyText && text[k].empty?}
      text['Warnings']['artifacts'] = ['No valid artifacts were found. Try checking Warnings for more info.'] if emptyText
      text['Warnings']['issueKeys'] = [] if emptyText
      return text
    end
# Make warning text
#
    def self.make_warning_text releaseList, jiraOwnerName, useWarn
      nlc = @@configs[jiraOwnerName]['NewLineChar'] ? @@configs[jiraOwnerName]['NewLineChar'] : '\n'
      text = Hash.new
      text['keys'] = []
      tempLastError = ''
      releaseList['list'].each do |k,v|
        type = v['installationNotes']['Type']
        text[v['assignee']] = '' if text[v['assignee']].nil?
        typeOk = ['Release Features', 'Enhancements', 'Fixes'].include? type
        statusOk = @@configs[jiraOwnerName]['DeployStatus'].include? v['status']
        error = !v['installationNotes']['error'].nil?
        text[v['assignee']] += "#{k} - Incorrect type : '#{type}'.#{nlc}" unless typeOk
        text[v['assignee']] += "#{k} - #{v['installationNotes']['error']}#{nlc}" if error
        text[v['assignee']] += "#{k} - Incorrect status : '#{v['status']}' is not deploy ready.#{nlc}" unless statusOk
        text['keys'] << "#{k}" if !typeOk or !statusOk or error
      end
      @@lastError = ""
      text
    end
end# Code António Almeida
