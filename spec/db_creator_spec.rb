describe RdsServiceBroker::DbCreator do
  describe '.run' do
    def set_up_instance_mock
      endpoint = double(address: 'foo.bar.com', port: 5432)
      instance = instance_double(Aws::RDS::DBInstance,
        db_name: 'myapp',
        endpoint: endpoint,
        master_username: 'myapp'
      )
      instances_resp = double(db_instances: [instance])
      expect_any_instance_of(Aws::RDS::Client).to receive(:describe_db_instances).and_return(instances_resp)
    end

    before do
      # TODO unset after test
      ENV['AWS_ACCESS_KEY_ID'] = 'keyid'
      ENV['AWS_SECRET_ACCESS_KEY'] = 'secretkey'
      ENV['SUBNET'] = 'foo'
      ENV['VPC_GROUP_ID'] = 'bar'
    end

    it "sends the creation info to the AWS API" do
      allow_any_instance_of(RdsServiceBroker::Options).to receive(:db_pass).and_return('randompass')
      expect_any_instance_of(Aws::RDS::Client).to receive(:create_db_instance).with(
        engine: 'postgres',
        db_name: 'myapp',
        db_instance_identifier: 'cf-myapp-myenv',
        master_username: 'myapp',
        master_user_password: 'randompass',
        tags: [
          {
            key: 'client',
            value: 'CAP-20140930-20150930-01'
          }
        ],
        auto_minor_version_upgrade: true,
        backup_retention_period: 7,
        db_subnet_group_name: 'foo',
        publicly_accessible: false,
        vpc_security_group_ids: ['bar'],
        allocated_storage: 5,
        db_instance_class: 'db.m1.small',
        multi_az: false,
        storage_type: 'standard'
      )
      expect_any_instance_of(Aws::RDS::Client).to receive(:wait_until)

      set_up_instance_mock

      RdsServiceBroker::DbCreator.run('cap', 'myapp', 'myenv', 'postgres-basic')
    end

    it "prints the database URL" do
      allow_any_instance_of(RdsServiceBroker::Options).to receive(:db_pass).and_return('randompass')
      expect_any_instance_of(Aws::RDS::Client).to receive(:create_db_instance)
      expect_any_instance_of(Aws::RDS::Client).to receive(:wait_until)

      set_up_instance_mock

      expect {
        RdsServiceBroker::DbCreator.run('cap', 'myapp', 'myenv', 'postgres-basic')
      }.to output(%r{postgresql://myapp:randompass@foo\.bar\.com:5432/myapp}).to_stdout
    end
  end
end
