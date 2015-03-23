module RdsServiceBroker
  class Options
    attr_reader :app_name, :env, :org, :plan

    def initialize(org, app_name, env, plan)
      @app_name = app_name
      @env = env
      @org = org
      @plan = plan
    end

    def engine
      self.plan.split('-').first
    end

    def plan_size
      self.plan.split('-').last
    end

    def db_name
      self.app_name
    end

    def db_instance_id
      "cf-#{self.app_name}-#{self.env}"
    end

    def db_user
      self.app_name
    end

    def db_pass
      @db_pass ||= SecureRandom.hex(50)
    end

    def org_options
      OrgOptions.by_name(self.org)
    end

    def client_tag
      self.org_options[:tag]
    end

    def subnet
      ENV.fetch('SUBNET')
    end

    def vpc_group_id
      ENV.fetch('VPC_GROUP_ID')
    end

    def general_opts
      # http://docs.aws.amazon.com/sdkforruby/api/Aws/RDS/Client.html#create_db_instance-instance_method
      {
        engine: engine,
        db_name: db_name,
        db_instance_identifier: db_instance_id,
        master_username: db_user,
        master_user_password: db_pass,
        tags: [
          {
            key: 'client',
            value: client_tag
          },
        ],

        auto_minor_version_upgrade: true,
        backup_retention_period: 7,
        db_subnet_group_name: subnet,
        publicly_accessible: false,
        vpc_security_group_ids: [vpc_group_id]
      }
    end

    def plan_opts
      PlanOptions.by_size(self.plan_size)
    end

    def to_hash
      opts = self.general_opts
      opts.merge!(self.plan_opts)
      opts
    end
  end
end
