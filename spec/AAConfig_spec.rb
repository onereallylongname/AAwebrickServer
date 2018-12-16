require './lib/aaServer/AAConfigs'

describe 'AAConfig' do
  describe "#set_tool" do
    context "Passing Test" do
      it "returns @@options[:schema]['Tools'] as Array" do
        expect(AAConfig.set_tool "Jira").to be_kind_of Array
      end
    end
    context "Passing Test" do
      it "raises error" do
        expect{AAConfig.set_tool 5}.to raise_error(AAConfig::InvalidArgument)
      end
    end
  end
  describe "#options" do
    context "Passing Test" do
      it "returns @@options as Hash" do
        expect(AAConfig.options).to be_kind_of Hash
      end
    end
  end
  describe "#configPath" do
    context "Passing Test" do
      it "returns true" do
        expect(AAConfig.config_path "Config.yml" ).to be true
      end
    end
    context "Failing Test" do
      it "returns false" do
        expect(AAConfig.config_path "adskjskdkml" ).to be false
      end
    end
  end
  describe "#validate_schema" do
    context "Failing Test" do
      it "returns false" do
        expect(AAConfig.validate_schema({'test': 'test'}) ).to be false
      end
      it "raise error" do
        expect{AAConfig.validate_schema 5}.to raise_error(AAConfig::InvalidArgument)
      end
    end
  end
end
