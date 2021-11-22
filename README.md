# rds-mysql CfHighlander component

## Build status
![cftest workflow](https://github.com/theonestack/hl-component-rds-mysql/actions/workflows/rspec.yaml/badge.svg)
## Parameters

| Name | Use | Default | Global | Type | Allowed Values |
| ---- | --- | ------- | ------ | ---- | -------------- |
| EnvironmentName | Tagging | dev | true | string
| EnvironmentType | Tagging | development | true | string | ['development','production']
| SubnetIds | List of subnets | None | false | CommaDelimitedList
| RDSInstanceType | RDS Instance Type to use | None | false | string
| RDSAllocatedStorage | Amount of storage in GB to assign | None | false | string
| DnsDomain | DNS domain to use | None | true | string
| MultiAZ | Specifies whether the database instance is a multiple Availability Zone deployment  | false | false | ['true','false']
| RDSSnapshotID | The name or Amazon Resource Name (ARN) of the DB snapshot that's used to restore the DB instance | false | false | string

## Outputs/Exports

| Name | Value | Exported |
| ---- | ----- | -------- |
| SecurityGroup | Security Group Name | true
| DBIdentifier | RDS Identifier | true

## Included Components

[lib-ec2](https://github.com/theonestack/hl-component-lib-ec2)

## Example Configuration
### Highlander
```
  Component name:'database', template: 'rds-postgres' do
    parameter name: 'DnsDomain', value: root_domain
    parameter name: 'DnsFormat', value: FnSub("${EnvironmentName}.#{root_domain}")
    parameter name: 'SubnetIds', value: cfout('vpcv2', 'PersistenceSubnets')
    parameter name: 'RDSInstanceType', value: 'db.m5.large'
    parameter name: 'MultiAZ', value: 'false'
    parameter name: 'StackOctet', value: '120'
    parameter name: 'RDSAllocatedStorage', value: '100'
  end

```

### RDS-MYSQL Configuration

```
engine: mysql
engine_version: '5.7.22'
family: mysql5.7
dns_record: db
deletion_policy: Snapshot

parameters:
  authentication_timeout: '60'

db_instance_name: app1intance
storage_encrypted: true
backup_retention_period: 7

security_group:
  -
    rules:
      -
        IpProtocol: tcp
        FromPort: 3306
        ToPort: 3306
    ips:
      - stack

master_login:
  username_ssm_param: /project/rds/RDS_MASTER_USERNAME
  password_ssm_param: /project/rds/RDS_MASTER_PASSWORD

```

## Cfhighlander Setup

install cfhighlander [gem](https://github.com/theonestack/cfhighlander)

```bash
gem install cfhighlander
```

or via docker

```bash
docker pull theonestack/cfhighlander
```
## Testing Components

Running the tests

```bash
cfhighlander cftest rds-mysql
```