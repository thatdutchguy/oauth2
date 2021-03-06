require 'helper'

describe OAuth2::Strategy::Assertion do
  let(:client) do
    cli = OAuth2::Client.new('abc', 'def', :site => 'http://api.example.com')
    cli.connection.build do |b|
      b.adapter :test do |stub|
        stub.post('/oauth/token') do |env|
          case @mode
            when "formencoded"
              [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, 'expires_in=600&access_token=salmon&refresh_token=trout']
            when "json"
              [200, {'Content-Type' => 'application/json'}, '{"expires_in":600,"access_token":"salmon","refresh_token":"trout"}']
          end
        end
      end
    end
    cli
  end

  let(:params) { {:hmac_secret => 'foo'}}

  subject {client.assertion}

  describe "#authorize_url" do
    it "should raise NotImplementedError" do
      lambda {subject.authorize_url}.should raise_error(NotImplementedError)
    end
  end

  %w(json formencoded).each do |mode|
    describe "#get_token (#{mode})" do
      before do
        @mode = mode
        @access = subject.get_token(params)
      end

      it 'returns AccessToken with same Client' do
        @access.client.should == client
      end

      it 'returns AccessToken with #token' do
        @access.token.should == 'salmon'
      end

      it 'returns AccessToken with #expires_in' do
        @access.expires_in.should == 600
      end

      it 'returns AccessToken with #expires_at' do
        @access.expires_at.should_not be_nil
      end
    end
  end

end

