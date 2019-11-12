CfhighlanderTemplate do
  Name 'rdsMySQL'
  Description "#{component_name} - #{component_version}"
  ComponentVersion component_version
  DependsOn 'vpc'

  Parameters do
    ComponentParam 'VPCId', type: 'AWS::EC2::VPC::Id'
    ComponentParam 'NetworkPrefix', isGlobal: true
    ComponentParam 'StackOctet', isGlobal: true
    ComponentParam 'RDSSnapshotID'
    ComponentParam 'MultiAZ', 'false', allowedValues: ['true','false']
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', isGlobal: true, allowedValues: ['development', 'production']
    ComponentParam 'RDSInstanceType'
    ComponentParam 'RDSAllocatedStorage'
    ComponentParam 'DnsDomain'
    ComponentParam 'SubnetIds', type: 'CommaDelimitedList'
  end
end
