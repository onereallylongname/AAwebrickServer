# spec/AABaseActions.rb
require './lib/aaServer/AAJira'

describe 'AAJira' do
  describe "#login" do
    context "Passing Test" do
      it "returns a Jira::Client" do
        jiraUser  = 'antonio.miguel.almeida@celfocus.com'
        jiraPass  = '-'
        jiraOwner = 'Celfocus'
        client = AAJira.login jiraUser, jiraPass, jiraOwner
        expect(client).to be_kind_of JIRA::Client
      end
      it "Has no lastError" do
        lastError = AAJira.lastError
        expect(lastError).to eq ''
      end
    end
    context "Faling Test - login is Invalid" do
      it "returns a nil" do
        jiraUser  = 'antonio.miguel.almeida@celfocus.com'
        jiraPass  = ''
        jiraOwner = 'Celfocus'
        testReturn = AAJira.login jiraUser, jiraPass, jiraOwner
        expect(testReturn).to be nil
      end
      it "Has lastError like 'Unable to connect to Jira.'" do
        lastError = AAJira.lastError
        expect(lastError.include? 'Unable to connect to Jira.').to be true
      end
    end
    context "Faling Test - jiraOwner Invalid" do
      it "returns a nil" do
        jiraUser  = 'antonio.miguel.almeida@celfocus.com'
        jiraPass  = ''
        jiraOwner = 'sdfsdf'
        testReturn = AAJira.login jiraUser, jiraPass, jiraOwner
        expect(testReturn).to be nil
      end
      it "Has lastError like 'Invalid jiraOwner.'" do
        lastError = AAJira.lastError
        expect(lastError.include? 'Invalid jiraOwner.').to be true
      end
    end
  end
end
