require 'spec_helper'
require_relative  "../../dns_record_created_event_handler/dns_record_created_event_handler"
describe Daemons::DnsRecordCreatedEventHandler do
  let(:config){
    {
      "pantry" => {
        "api_key" => "some_api_key",
        "request_timeout" => 10,
        "url" => "http://some.url"
      }
    }
  }
  let(:good_message_hash) {
    {
      "pantry_request_id" => 1,
      "instance_id" => "i-f4819cb9"
    }
  }

  subject { Daemons::DnsRecordCreatedEventHandler.new(config) }

  describe "#handle_message" do
    before(:each) do
      WebMock.reset!
    end

    context "HTTP200" do
      it "Receives a correct SQS message and proceeds" do
       WebMock.stub_request(:put, "http://some.url/aws/ec2_instances/1").
         with(:body => "{\"joined\":true}",
              :headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'Content-Length'=>'15', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby', 'X-Auth-Token'=>'some_api_key'}).
         to_return(:status => 200, :body => "", :headers => {})
        expect(subject.handle_message(good_message_hash).code).to be 200
      end
    end

    context "HTTP200" do
      it "Receives an incorrect SQS message and errors" do
       WebMock.stub_request(:put, "http://some.url/aws/ec2_instances/1").
         with(:body => "{\"joined\":true}",
              :headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'Content-Length'=>'15', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby', 'X-Auth-Token'=>'some_api_key'}).
         to_return(:status => 500, :body => "", :headers => {})
        expect{subject.handle_message(good_message_hash)}.to raise_error(RestClient::InternalServerError)
      end
    end 
  end
end
