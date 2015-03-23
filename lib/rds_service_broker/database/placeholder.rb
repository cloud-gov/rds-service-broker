module RdsServiceBroker
  module Database
    class Placeholder
      attr_reader :opts

      delegate :db_instance_id, :db_pass, to: :opts

      def initialize(opts)
        @opts = opts
      end

      def client
        @client ||= Aws::RDS::Client.new(region: 'us-east-1')
      end

      def create
        self.client.create_db_instance(self.opts.to_hash)
      end

      # blocks via `sleep`
      def wait_for_instance_available
        print "Waiting"
        client.wait_until(:db_instance_available, db_instance_identifier: db_instance_id) do |w|
          w.before_wait do |attempts, response|
            print '.'
          end
        end
        print "\n"
      end

      def fetch_instance
        resp = client.describe_db_instances(db_instance_identifier: db_instance_id)
        resp.db_instances.first
      end

      def fetch_available_instance
        puts "Retrieving instance details..."
        self.wait_for_instance_available
        self.fetch_instance
      end

      def available_instance
        @available_instance ||= self.fetch_available_instance
      end
    end
  end
end
