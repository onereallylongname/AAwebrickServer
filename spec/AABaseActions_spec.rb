# spec/AABaseActions.rb
require './lib/aaServer/AABaseActions'

describe 'AABaseActions' do
  context "#version" do
    it "returns ['{'version': '<version in AAversion>'}', 200, 'text/json'] as array" do
      testReturn = AABaseActions.version
      expect(testReturn).to be_kind_of Array
      expect(testReturn.size).to eq 3
      expect(testReturn[0]).to be_kind_of String
      expect(testReturn[1]).to be_kind_of Integer
      expect(testReturn[2]).to be_kind_of String
    end
  end
  context "#badRequest" do
    it "returns ['{\"error\":\"400\",\"message\":\"Bad Request\",\"description\":\"test\"}', 200, 'text/json'] as array" do
      testReturn = AABaseActions.badRequest('test')
      expect(testReturn).to be_kind_of Array
      expect(testReturn.size).to eq 3
      expect(testReturn[0]).to be_kind_of String
      expect(testReturn[0]).to eq "{\"error\":\"400\",\"message\":\"Bad Request\",\"description\":\"test\"}"
      expect(testReturn[1]).to be_kind_of Integer
      expect(testReturn[2]).to be_kind_of String
    end
  end
  context "#setUnauthorized" do
    it "returns ['{\"error\":\"401\",\"message\":\"Unauthorized\",\"description\":\"test\"}', 200, 'text/json'] as array" do
      testReturn = AABaseActions.setUnauthorized('test')
      expect(testReturn).to be_kind_of Array
      expect(testReturn.size).to eq 3
      expect(testReturn[0]).to be_kind_of String
      expect(testReturn[0]).to eq "{\"error\":\"401\",\"message\":\"Unauthorized\",\"description\":\"test\"}"
      expect(testReturn[1]).to be_kind_of Integer
      expect(testReturn[2]).to be_kind_of String
    end
  end
  context "#setMethodNotAllowed" do
    it "returns ['{\"error\":\"405\",\"message\":\"Method Not Allowed\",\"description\":\"test\"}', 200, 'text/json'] as array" do
      testReturn = AABaseActions.setMethodNotAllowed('test')
      expect(testReturn).to be_kind_of Array
      expect(testReturn.size).to eq 3
      expect(testReturn[0]).to be_kind_of String
      expect(testReturn[0]).to eq "{\"error\":\"405\",\"message\":\"Method Not Allowed\",\"description\":\"test\"}"
      expect(testReturn[1]).to be_kind_of Integer
      expect(testReturn[2]).to be_kind_of String
    end
  end
end
