module RdsServiceBroker
  module DbCreator
    def run
      # TODO take as params
      app_name = 'c2'
      env = 'staging'
      plan = 'postgres-basic'

      opts = Options.new(app_name, env, plan)
      db = Database::Placeholder.new(opts)
      puts "Creating database instance: #{opts.db_instance_id}"
      db.create

      instance = db.available_instance
      wrapped = Database::Instance.new(instance, opts.db_pass)
      puts wrapped.database_url
    end
    module_function :run
  end
end
