module RdsServiceBroker
  class Database
    attr_reader :opts

    def initialize(opts)
      @opts = opts
    end

    def client
      @client ||= Aws::RDS::Client.new(region: 'us-east-1')
    end

    def db_instance_id
      self.opts[:db_instance_id]
    end

    def create
      self.client.create_db_instance(self.opts)
    end

    def wait_for_instance_available
      print "Waiting"
      # blocking (via `sleep`)
      client.wait_until(:db_instance_available, db_instance_identifier: db_instance_id) do |w|
        w.before_wait do |attempts, response|
          print '.'
        end
      end
      print "\n"
    end

    def instance
      resp = client.describe_db_instances(db_instance_identifier: db_instance_id)
      resp.db_instances.first
    end

    def fetch_available_instance
      self.wait_for_instance_available
      self.instance
    end

    def available_instance
      @available_instance ||= self.fetch_available_instance
    end

    def endpoint
      @endpoint ||= self.available_instance.endpoint
    end
  end
end
