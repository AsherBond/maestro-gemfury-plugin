require 'spec_helper'

describe MaestroDev::Plugin::GemfuryWorker do
  API_KEY = 'test_key'
  ACCOUNT = 'test_account'
  PATH = "#{File.dirname(__FILE__)}/gems"

  before :each do
    Maestro::MaestroWorker.mock!
    @workitem = {
      'fields' => {
        'account' => ACCOUNT,
        'user_api_key' => API_KEY,
        'file' => "#{PATH}/*.gem"
      }
    }
  end

  it 'should complain on missing config items' do
    workitem = {'fields' => {}}
    subject.perform(:push, workitem)

    workitem['fields']['__error__'].should include('missing field account')
    workitem['fields']['__error__'].should include('missing field user_api_key')
    workitem['fields']['__error__'].should include('missing field file')
  end

  it "should find all gems" do
    stub_request(:post, "https://www.gemfury.com/1/gems?as=test_account").to_return(:status => 200)

    subject.perform(:push, @workitem)

    @workitem['__output__'].should include("Uploading #{PATH}/a.gem")
    @workitem['__output__'].should include("Uploading #{PATH}/b.gem")
    @workitem['fields']['__error__'].should be_nil
  end
end
