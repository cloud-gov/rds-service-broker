require 'active_support/core_ext/hash/keys'
require 'aws-sdk'
require 'yaml'

module RdsServiceBroker
  module DbCreator
    def run
      # TODO take as params
      app_name = 'c2'
      env = 'staging'
      plan = 'postgres-basic'

      opts = Options.new(app_name, env, plan)
      db = Database.new(opts.to_hash)
      puts "Creating database instance: #{opts.db_instance_id}"
      db.create

      puts "Retrieving instance endpoint..."
      endpoint = db.endpoint

      # TODO change based on plan
      db_url = "postgresql://#{opts.db_user}:#{opts.db_pass}@#{endpoint.address}:#{endpoint.port}/#{opts.db_name}"
      puts db_url
    end
    module_function :run
  end
end
