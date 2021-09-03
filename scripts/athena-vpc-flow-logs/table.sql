-- Before you can create the table, 
-- please enable VPC flow logs on your AWS account

CREATE EXTERNAL TABLE IF NOT EXISTS vpc_default_flow_logs (
  account string,
  instanceid string,
  interfaceid string,
  azid string,
  sourceaddress string,
  destinationaddress string,
  sourceport int,
  destinationport int,
  numbytes bigint,
  pktsrcaddr string,
  pktdstaddr string,
  pktsrcawsservice string,
  pktdstawsservice string,
  region string,
  starttime int,
  endtime int,
  subnetid string,
  tcpflags int,
  trafficpath string,
  sublocationtype string,
  sublocationid string,
  protocol int,
  numpackets int,
  logstatus string,
  flowdirection string,
  action string,
  type string,
  version int,
  vpcid string
)
PARTITIONED BY (`date` Date)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' '
LOCATION 's3://vpc-flow-logs-v2/default/AWSLogs/accountID/vpcflowlogs/ap-xxx-1/'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Alter table to add partitions based on date period

ALTER TABLE vpc_default_flow_logs
ADD PARTITION (`date`='2021-05-19')
location 's3://vpc-flow-logs-v2/default/AWSLogs/accountId/vpcflowlogs/ap-xxx-1/2021/05/19';

DROP TABLE `vpc_default_flow_logs`;

SELECT * FROM vpc_default_flow_logs LIMIT 15;

CREATE EXTERNAL TABLE IF NOT EXISTS vpc_ebidding_flow_logs (
  account string,
  instanceid string,
  interfaceid string,
  azid string,
  sourceaddress string,
  destinationaddress string,
  sourceport int,
  destinationport int,
  numbytes bigint,
  pktsrcaddr string,
  pktdstaddr string,
  pktsrcawsservice string,
  pktdstawsservice string,
  region string,
  starttime int,
  endtime int,
  subnetid string,
  tcpflags int,
  trafficpath string,
  sublocationtype string,
  sublocationid string,
  protocol int,
  numpackets int,
  logstatus string,
  flowdirection string,
  action string,
  type string,
  version int,
  vpcid string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' '
LOCATION 's3://vpc-flow-logs-v2/xxx/AWSLogs/accountID/vpcflowlogs/ap-xxx-1/'
TBLPROPERTIES ("skip.header.line.count"="1");