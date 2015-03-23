require_relative 'lib/rds_service_broker'

# TODO take as params
org = 'cap'
app_name = 'c2'
env = 'staging'
plan = 'postgres-basic'

RdsServiceBroker::DbCreator.run(org, app_name, env, plan)
