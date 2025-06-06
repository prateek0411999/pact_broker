require "pact_broker/api/resources/base_resource"
require "pact_broker/configuration"
require "pact_broker/api/decorators/versions_decorator"
require "pact_broker/api/resources/pagination_methods"


module PactBroker
  module Api
    module Resources
      class Versions < BaseResource
        include PaginationMethods

        def content_types_provided
          [["application/hal+json", :to_json]]
        end

        def allowed_methods
          ["GET", "OPTIONS"]
        end

        def malformed_request?
          super || request.get? && validation_errors_for_schema?(schema, request.query)
        end

        def resource_exists?
          !!pacticipant
        end

        def to_json
          decorator_class(:versions_decorator).new(versions).to_json(**decorator_options(identifier_from_path.merge(deployed_versions: deployed_versions)))
        end

        def versions
          @versions ||= version_service.find_pacticipant_versions_in_reverse_order(pacticipant_name, {}, pagination_options, decorator_class(:versions_decorator).eager_load_associations)
        end

        def deployed_versions
          @deployed_versions ||= deployed_version_service.find_deployed_versions_for_versions(versions)
        end

        def policy_name
          :'versions::versions'
        end

        private

        def schema
          if request.get?
            PactBroker::Api::Contracts::PaginationQueryParamsSchema
          end
        end
      end
    end
  end
end
