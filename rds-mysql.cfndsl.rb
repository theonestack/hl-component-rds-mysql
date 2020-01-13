CloudFormation do

  Description "#{external_parameters[:component_name]} - #{external_parameters[:component_version]}"

  tags = []
  tags << { Key: 'Environment', Value: Ref(:EnvironmentName) }
  tags << { Key: 'EnvironmentType', Value: Ref(:EnvironmentType) }

  extra_tags = external_parameters.fetch(:extra_tags, {})
  extra_tags.each { |key,value| tags << { Key: key, Value: value } }

  EC2_SecurityGroup "SecurityGroupRDS" do
    VpcId Ref('VPCId')
    GroupDescription FnJoin(' ', [ Ref(:EnvironmentName), external_parameters[:component_name], 'security group' ])
    SecurityGroupIngress sg_create_rules(external_parameters[:security_group], external_parameters[:ip_blocks])
    Tags tags + [{ Key: 'Name', Value: FnJoin('-', [ Ref(:EnvironmentName), external_parameters[:component_name], 'security-group' ])}]
  end

  RDS_DBSubnetGroup 'SubnetGroupRDS' do
    DBSubnetGroupDescription FnJoin(' ', [ Ref(:EnvironmentName), external_parameters[:component_name], 'subnet group' ])
    SubnetIds Ref(:SubnetIds)
    Tags tags + [{ Key: 'Name', Value: FnJoin('-', [ Ref(:EnvironmentName), external_parameters[:component_name], 'subnet-group' ])}]
  end

  parameters = external_parameters.fetch(:parameters, {})
  RDS_DBParameterGroup 'ParametersRDS' do
    Description FnJoin(' ', [ Ref(:EnvironmentName), external_parameters[:component_name], 'parameter group' ])
    Family external_parameters[:family]
    Parameters parameters unless parameters.empty?
    Tags tags + [{ Key: 'Name', Value: FnJoin('-', [ Ref(:EnvironmentName), external_parameters[:component_name], 'parameter-group' ])}]
  end

  master_login = external_parameters.fetch(:master_login, {})
  RDS_DBInstance 'RDS' do
    DeletionPolicy external_parameters[:deletion_policy]
    DBInstanceClass Ref('RDSInstanceType')
    AllocatedStorage Ref('RDSAllocatedStorage')
    StorageType 'gp2'
    Engine 'mysql'
    EngineVersion external_parameters[:engine_version]
    DBParameterGroupName Ref('ParametersRDS')
    MasterUsername  FnJoin('', [ '{{resolve:ssm:', FnSub(master_login['username_ssm_param']), ':1}}' ]) unless master_login.empty?
    MasterUserPassword FnJoin('', [ '{{resolve:ssm-secure:', FnSub(master_login['password_ssm_param']), ':1}}' ]) unless master_login.empty?
    DBSnapshotIdentifier  Ref('RDSSnapshotID')
    DBSubnetGroupName  Ref('SubnetGroupRDS')
    VPCSecurityGroups [Ref('SecurityGroupRDS')]
    MultiAZ Ref('MultiAZ')
    Tags  tags + [
      { Key: 'Name', Value: FnJoin('-', [ Ref(:EnvironmentName), external_parameters[:component_name], 'instance' ])},
      { Key: 'SnapshotID', Value: Ref('RDSSnapshotID')},
      { Key: 'Version', Value: external_parameters[:family]}
    ]
  end

  record = external_parameters.fetch(:dns_record, 'mysql')

  Route53_RecordSet('DatabaseIntHostRecord') do
    HostedZoneName FnJoin('', [ Ref('EnvironmentName'), '.', Ref('DnsDomain'), '.'])
    Name FnJoin('', [ record, '.', Ref('EnvironmentName'), '.', Ref('DnsDomain'), '.' ])
    Type 'CNAME'
    TTL 60
    ResourceRecords [ FnGetAtt('RDS','Endpoint.Address') ]
  end

end
