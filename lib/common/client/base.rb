# frozen_string_literal: true
require 'faraday'
require 'common/client/errors'
require 'common/models/collection'
require 'sentry_logging'

module Common
  module Client
    class Base
      include SentryLogging

      class << self
        def configuration(configuration = nil)
          @configuration ||= configuration.instance
        end
      end

      private

      def config
        self.class.configuration
      end

      # memoize the connection from config
      def connection
        @connection ||= config.connection
      end

      def perform(method, path, params, headers = nil, yielder = nil)
        raise NoMethodError, "#{method} not implemented" unless config.request_types.include?(method)

        if yielder.present?
          send(method, path, params || {}, headers || {}, yielder)
        else
          send(method, path, params || {}, headers || {})
        end
      end

      def request(method, path, params = {}, headers = {}, yielder = nil)
        raise_not_authenticated if headers.keys.include?('Token') && headers['Token'].nil?
        if yielder.nil?
          connection.send(method.to_sym, path, params) { |request| request.headers.update(headers) }.env
        else
          binding.pry
          streamed = []
          connection.send(method.to_sym, path, params) do |request|
            request.headers.update(headers)
            request.options.on_data = Proc.new do |chunk, overall_received_bytes|
              puts "Received #{overall_received_bytes} characters"
              yielder << chunk
            end
          end
        end
      rescue Timeout::Error, Faraday::TimeoutError
        log_message_to_sentry(
          "Timeout while connecting to #{config.service_name} service", :error, extra_context: { url: config.base_path }
        )
        raise Common::Exceptions::GatewayTimeout
      rescue Faraday::ParsingError => e
        # Faraday::ParsingError is a Faraday::ClientError but should be handled by implementing service
        raise e
      rescue Faraday::ClientError => e
        client_error = Common::Client::Errors::ClientError.new(
          e.message,
          e.response&.dig(:status),
          e.response&.dig(:body)
        )
        raise client_error
      end

      def get(path, params, headers = base_headers, yielder = nil)
        request(:get, path, params, headers, yielder)
      end

      def post(path, params, headers = base_headers)
        request(:post, path, params, headers)
      end

      def put(path, params, headers = base_headers)
        request(:put, path, params, headers)
      end

      def delete(path, params, headers = base_headers)
        request(:delete, path, params, headers)
      end

      def raise_not_authenticated
        raise Common::Client::Errors::NotAuthenticated, 'Not Authenticated'
      end
    end
  end
end
