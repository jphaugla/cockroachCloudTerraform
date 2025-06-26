VPCE_ID=$(terraform state show module.my_aws.module.crdb-region-0.aws_vpc_endpoint.crdb \
  | awk '/^ *id =/ { print $3 }')

aws ec2 describe-vpc-endpoints \
  --vpc-endpoint-ids $VPCE_ID \
  --region us-east-1 \
  --query 'VpcEndpoints[0].{State:State, PrivateDNS:PrivateDnsEnabled, DNS:DnsEntries}' \
  --output json

