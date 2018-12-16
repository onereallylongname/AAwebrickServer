# How to use
### Start server
0. Install Ruby
1. Set you configurations in the Config.yml file
  - Be careful when editing the file! Deleting a configuration will result cause errors in the code.
2. Run command 'ruby webrickServer.rb'
   - If you're not currently in the 'webrickServerJira' folder run 'ruby <path to folder>/webrickServer.rb'

### Services
1. Static server
  - Serve any static file present in the RootDir.
2. REST, for Jira Release Management
  - '< service path\>/test'
    - Test
  - '< service path\>/get/pid?id=< valid id\>'
    - Get server process id.
  - '< service path\>/restart?id=< valid id\>'
    - Restart server. WARNING : This will not produce a response! All sessions will be lost.
  - '< service path\>/sessions/get?id=< valid id\>'
    - Get all sessions.
  - '< service path\>/sessions/get?id=< valid id\>&getId=< session id to get\>'
    - Get one session id sessions.
  - '< service path\>/jira/get/release?id=< valid id\>&release=<release\>'
    - Can only be called after a successful jira login.
    - Query Jira for the release (for one component), and load relevant information to memory.
  - '< service path\>/jira/get/info/confluence?id=< valid id\>'
    - Can only be called after a successful get release.
    - Get text for Confluence.
  - '< service path\>/jira/get/info/jira?id=< valid id\>'
    - Can only be called after a successful get release.
    - Get text for Jira release issue.
  - '< service path\>/jira/get/info/release?id=< valid id\>'
    - Can only be called after a successful get release.
    - Get list summarizing issues for Release.
  - '< service path\>/jira/get/info/resolve?id=< valid id\>'
    - Can only be called after a successful get release.
    - Get list of artefacts to deliver.
  - '< service path\>/jira/get/info/warning?id=< valid id\>'
    - Can only be called after a successful get release.
    - Get list of warnings for release manager.
  - '< service path\>/login?id=< id to set as session key\>'
    - The id sent will be your session key.
  - '< service path\>/jira/login?id=< id to set as session key\>&jiraUser=< valid jira user\>&jiraPass=< valid jira password\>&jiraOwner=< owner : Celfocus / Vodafone\>
    - The id sent will be your session key.
    - jiraUser and jiraPass must be you jira credentials.
  - '< service path\>/logout?id=< valid session id \>
    - The session with the id sent will be terminated, if the session request is valid.


### Reconfigure server
**If all is Ok**
 1. Change Config.yml
 2. Use restart service '<host\>:<port\><service path\>restart?id=< your session id\>'

**If you need to force a restart**
1. Change Config.yml
2. Go to log files
  1. Search for last line containing 'INFO  WEBrick::HTTPServer#start:'
  2. In that line you can find the pid of the process
3. Kill the process
  - Windows: Taskkill /PID <pid\> /F
  - Linux: kill -9 <pid\>
4. Run the command 'ruby webrickServer.rb'

By António Almeida
