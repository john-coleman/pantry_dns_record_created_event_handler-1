require 'spec_helper'
require_relative  "../../dns_record_created_event_handler/dns_record_created_event_handler"
describe Wonga::Daemon::DnsRecordCreatedEventHandler do
  let(:config) {
    {
      "pantry" => {
        "api_key" => "some_api_key",
        "request_timeout" => 10,
        "url" => "http://some.url"
      }
    }
  }
  let(:url) { config["pantry"]["url"] }
  let(:api_key) { config["pantry"]["api_key"] }
  let(:good_message_hash) {
    {
      "pantry_request_id" => 1,
      "instance_id" => "i-f4819cb9"
    }
  }
  let(:logger) { instance_double('Logger').as_null_object }

  subject { Wonga::Daemon::DnsRecordCreatedEventHandler.new(config, logger) }

  it_behaves_like "handler"

  describe "#handle_message" do
    before(:each) do
      WebMock.reset!
    end

    context "HTTP200" do
      it "Receives a correct SQS message and proceeds" do
        WebMock.stub_request(:put, "#{url}/aws/ec2_instances/1").
          with(:body => "{\"joined\":true,\"instance_id\":\"i-f4819cb9\"}",
               :headers => {'Accept'=>'application/json',
                            'Content-Type'=>'application/json',
                            'X-Auth-Token'=>'some_api_key'}).
                            to_return(:status => 200, :body => "", :headers => {})
        expect(subject.handle_message(good_message_hash).code).to be 200
      end
    end

    context "HTTP500" do
      it "Receives an incorrect SQS message and raises an error" do
        WebMock.stub_request(:put, "#{url}/aws/ec2_instances/1").
          with(:body => "{\"joined\":true,\"instance_id\":\"i-f4819cb9\"}",
               :headers => {'Accept'=>'application/json',
                            'Content-Type'=>'application/json',
                            'X-Auth-Token'=>'some_api_key'}).
                            to_return(:status => 500, :body => "", :headers => {})
        expect{subject.handle_message(good_message_hash)}.to raise_error(RestClient::InternalServerError)
      end
    end 
  end
end
