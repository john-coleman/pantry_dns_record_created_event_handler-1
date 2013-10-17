require 'spec_helper'
require_relative  "../../dns_record_created_event_handler/dns_record_created_event_handler"
describe Wonga::Daemon::DnsRecordCreatedEventHandler do
  let(:api_client) { instance_double('Wonga::Daemon::PantryApiClient').as_null_object }
  let(:logger) { instance_double('Logger').as_null_object }
  subject { described_class.new(api_client, logger) }
  let(:message) { { "pantry_request_id"=>40, "instance_id"=>"i-0123abcd" } }
  it_behaves_like "handler"

  it "updates Pantry using PantryApiClient" do
    expect(api_client).to receive(:send_put_request).with("/api/ec2_instances/40", { joined: true })
    subject.handle_message(message)
  end
end
