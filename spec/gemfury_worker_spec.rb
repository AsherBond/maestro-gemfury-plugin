require 'spec_helper'

describe MaestroDev::GemfuryPlugin::GemfuryWorker do
  before :all do
    @test_participant = MaestroDev::GemfuryPlugin::GemfuryWorker.new
  end

  it "should find all gems" do
    gems = ["#{File.dirname(__FILE__)}/gems/a.gem", "#{File.dirname(__FILE__)}/gems/b.gem"]
    @test_participant.find_gems("#{File.dirname(__FILE__)}/gems/*.gem").should eq(gems)
  end

  it "should push a gem" do
    wi = {'fields' => {
      "account" => "test",
      "user_api_key" => "xyz",
      "file" => "#{File.dirname(__FILE__)}/gems/*.gem"
    }}

    client = mock()
    client.expects(:push_gem).with(instance_of File).twice

    @test_participant.expects(:connect).with("xyz", "test").returns(client)
    @test_participant.expects(:workitem => wi).at_least_once
    @test_participant.expects(:write_output).with(regexp_matches(/Uploading #{File.dirname(__FILE__)}\/gems\/a.gem to Gemfury/))
    @test_participant.expects(:write_output).with(regexp_matches(/Uploading #{File.dirname(__FILE__)}\/gems\/b.gem to Gemfury/))
    @test_participant.expects(:write_output).with(regexp_matches(/uploaded/)).twice

    @test_participant.push

    wi['fields']['__error__'].should be_nil
  end
end
