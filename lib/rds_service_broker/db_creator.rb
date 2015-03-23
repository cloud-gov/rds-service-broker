module RdsServiceBroker
  module DbCreator
    def run
      # TODO take as params
      org = 'cap'
      app_name = 'c2'
      env = 'staging'
      plan = 'postgres-basic'

      opts = Options.new(org, app_name, env, plan)
      db = Database::Placeholder.new(opts)
      db.create

      instance = db.available_instance
      wrapped = Database::Instance.new(instance, opts.db_pass)
      puts wrapped.database_url
    end
    module_function :run
  end
end
