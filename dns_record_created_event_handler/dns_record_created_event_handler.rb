module Wonga
  module Daemon
    class DnsRecordCreatedEventHandler

      def initialize(api_client, logger)
        @api_client = api_client
        @logger = logger
      end

      def handle_message(message)
        @logger.info "Updating booted status for Request:#{message["pantry_request_id"]}, Name:#{message["instance_name"]}, InstanceID:#{message["instance_id"]}"
        response = @api_client.update_ec2_instance(message["pantry_request_id"], { joined: true, instance_id: message["instance_id"]})
        @logger.info "Updating dns created status for Request:#{message["pantry_request_id"]} succeeded"
      end
    end
  end
end
