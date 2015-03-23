describe 'DbCreator' do
  describe '.run' do
    before do
      # TODO unset after test
      ENV['AWS_ACCESS_KEY_ID'] = 'keyid'
      ENV['AWS_SECRET_ACCESS_KEY'] = 'secretkey'
      ENV['SUBNET'] = 'foo'
      ENV['VPC_GROUP_ID'] = 'bar'
    end

    it "sends the creation info to the AWS API" do
      expect_any_instance_of(Aws::RDS::Client).to receive(:create_db_instance).with(
        engine: 'postgres',
        db_name: 'c2',
        db_instance_identifier: 'cf-c2-staging',
        master_username: 'c2',
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

      endpoint = double(address: 'foo.bar.com', port: 5432)
      instance = instance_double(Aws::RDS::DBInstance, endpoint: endpoint)
      instances_resp = double(db_instances: [instance])
      expect_any_instance_of(Aws::RDS::Client).to receive(:describe_db_instances).and_return(instances_resp)

      RdsServiceBroker::DbCreator.run
    end

    it "prints the database URL" do
      expect_any_instance_of(Aws::RDS::Client).to receive(:create_db_instance)
      expect_any_instance_of(Aws::RDS::Client).to receive(:wait_until)

      endpoint = double(address: 'foo.bar.com', port: 5432)
      instance = instance_double(Aws::RDS::DBInstance, endpoint: endpoint)
      instances_resp = double(db_instances: [instance])
      expect_any_instance_of(Aws::RDS::Client).to receive(:describe_db_instances).and_return(instances_resp)

      expect {
        RdsServiceBroker::DbCreator.run
      }.to output(%r{postgresql://c2:randompass@foo\.bar\.com:5432/c2}).to_stdout
    end
  end
end
