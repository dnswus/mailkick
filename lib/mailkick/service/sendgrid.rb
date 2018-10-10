# https://github.com/freerobby/sendgrid_toolkit

module Mailkick
  class Service
    class Sendgrid < Mailkick::Service
      def initialize(options = {})
        @api_user = options[:api_user] || ENV["SENDGRID_USERNAME"]
        @api_key = options[:api_key] || ENV["SENDGRID_PASSWORD"]
      end

      # TODO paginate
      def opt_outs
        unsubscribes + spam_reports + bounces
      end

      def unsubscribes
        fetch(::SendgridToolkit::Unsubscribes, "unsubscribe")
      end

      def spam_reports
        fetch(::SendgridToolkit::SpamReports, "spam")
      end

      def bounces
        fetch(::SendgridToolkit::Bounces, "bounce")
      end

      def self.discoverable?
        !!(defined?(::SendgridToolkit) && ENV["SENDGRID_USERNAME"] && ENV["SENDGRID_PASSWORD"])
      end

      def remove_opt_out(email, reason)
        case reason
        when "unsubscribe"
          remove(::SendgridToolkit::Unsubscribes, email)
        when "spam"
          remove(::SendgridToolkit::SpamReports, email)
        when "bounce"
          remove(::SendgridToolkit::Bounces, email)
        end
      end

      protected

      def fetch(klass, reason)
        klass.new(@api_user, @api_key).retrieve_with_timestamps.map do |record|
          {
            email: record["email"],
            time: record["created"],
            reason: reason
          }
        end
      end

      def remove(klass, email)
        klass.new(@api_user, @api_key).delete({ email: email })
      end
    end
  end
end
