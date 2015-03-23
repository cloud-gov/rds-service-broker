require 'active_support/core_ext/hash/keys'
require 'aws-sdk'
require 'yaml'

module DbCreator
  PLANS = YAML.load_file('plans.yml')
  PLANS.each do |plan, opts|
    opts.symbolize_keys!
  end

  def generate_plan_opts(plan_size)
    PLANS[plan_size] || raise("unknown plan size #{plan_size.inspect}")
  end
  module_function :generate_plan_opts

  def run
    rds = Aws::RDS::Client.new(region: 'us-east-1')

    # TODO take as params
    app_name = 'c2'
    env = 'staging'
    plan = 'postgres-basic'
    # TODO map org name to tag value
    client_tag = 'CAP-20140930-20150930-01'

    # TODO take as configuration
    subnet = ENV.fetch('SUBNET')
    vpc_group_id = ENV.fetch('VPC_GROUP_ID')


    engine, plan_size = plan.split('-')
    db_name = app_name
    db_instance_id = "cf-#{app_name}-#{env}"
    db_user = app_name
    # TODO make random
    db_pass = 'randompass'

    # http://docs.aws.amazon.com/sdkforruby/api/Aws/RDS/Client.html#create_db_instance-instance_method
    opts = {
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

    plan_opts = generate_plan_opts(plan_size)
    opts.merge!(plan_opts)


    puts "Creating database instance: #{db_instance_id}"
    rds.create_db_instance(opts)

    print "Waiting"
    # blocking (via `sleep`)
    rds.wait_until(:db_instance_available, db_instance_identifier: db_instance_id) do |w|
      w.before_wait do |attempts, response|
        print '.'
      end
    end
    print "\n"

    puts "Retrieving instance endpoint..."
    resp = rds.describe_db_instances(db_instance_identifier: db_instance_id)
    instance = resp.db_instances.first
    endpoint = instance.endpoint

    # TODO change based on plan
    db_url = "postgresql://#{db_user}:#{db_pass}@#{endpoint.address}:#{endpoint.port}/#{db_name}"
    puts db_url
  end
  module_function :run
end

# if file is run directly
if __FILE__ == $0
  DbCreator.run
end
