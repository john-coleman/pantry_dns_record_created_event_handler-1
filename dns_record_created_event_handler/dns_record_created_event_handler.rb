require 'json'
require 'rest_client'
module Wonga
  module Daemon
    class DnsRecordCreatedEventHandler

      def initialize(config, logger)
        @config = config
        @logger = logger
      end

      def handle_message(message)
        base_url = @config["pantry"]["url"]
        request_id = message["pantry_request_id"]
        update = ({:joined=>true,:instance_id=>message["instance_id"]}).to_json
        @logger.info "Updating booted status for Request:#{request_id}, Name:#{message["instance_name"]}, InstanceID:#{message["instance_id"]}"
        site = RestClient::Resource.new(
          "#{base_url}",
          timeout: @config["pantry"]["request_timeout"]
        )
        response = site["/aws/ec2_instances/#{request_id}"].put(
          update,
            {
            :accept         => :json,
            :content_type   => :json,
            :'x-auth-token' => @config["pantry"]["api_key"]
          }
        )
        case response.code
        when 200
          @logger.info "Updating dns created status for Request:#{request_id} succeeded"
        else
          @logger.error "Updating dns created status for Request:#{request_id} failed with #{response}"
        end
        response
      end

    end
  end
end
