describe 'DbCreator' do
  describe '.run' do
    it "sends the creation info to the AWS API" do
      # TODO unset after test
      ENV['SUBNET'] = 'foo'
      ENV['VPC_GROUP_ID'] = 'bar'

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
  end
end
