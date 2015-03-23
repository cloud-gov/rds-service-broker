# wrapper for an Aws::RDS::DBInstance
module RdsServiceBroker
  module Database
    class Instance
      attr_reader :db_pass, :sdk_instance

      delegate :db_name, :master_username, :endpoint, to: :sdk_instance

      def initialize(sdk_instance, db_pass)
        @db_pass = db_pass
        @sdk_instance = sdk_instance
      end

      def database_url
        # TODO change based on engine
        "postgresql://#{self.master_username}:#{self.db_pass}@#{endpoint.address}:#{endpoint.port}/#{self.db_name}"
      end
    end
  end
end
