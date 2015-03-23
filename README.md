# RDS Service Broker for Cloud Foundry

(Eventually will be) a [service](http://docs.cloudfoundry.org/services/) broker for [Cloud Foundry](http://cloudfoundry.org), which will create and manage [Relational Database Service](http://aws.amazon.com/rds/) instances in [Amazon Web Services](http://aws.amazon.com/).

## Current status

Currently just a script that needs to be run manually.

## Usage

1. Set up your [AWS credentials](http://docs.aws.amazon.com/sdkforruby/api/index.html#Credentials).
1. Clone this repository.
1. From within the project directory, run

    ```bash
    bundle
    SUBNET=... VPC_GROUP_ID=... bundle exec ruby create_db.yml
    ```

1. Set the resulting `DATABASE_URL` as an environment variable in your application.
