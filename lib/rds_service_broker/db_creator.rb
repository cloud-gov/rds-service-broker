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
      db = Database.new(opts)
      puts "Creating database instance: #{opts.db_instance_id}"
      db.create

      puts db.database_url
    end
    module_function :run
  end
end
