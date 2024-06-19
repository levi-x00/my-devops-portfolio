# My DevOps Portofolio

This repo showcases of my research and development (RnD) and my experience working as Cloud/DevOps/Site Reliability Engineer and any related field while keeping all proprietary confidential.

The following some projects that I worked in the past.

## ELK Stacks

![Alt text](./images/cwlogs-to-es.drawio.svg?raw=true "Centralize Logs in ElasticSearch")

- Events, audit, application (info, error, audit), and anti virus logs collected to CloudWatch Logs then parsed using lambda function to ElasticSearch (Amazon OpenSearch)
- CloudTrail events collected to CloudWatch Logs then parsed to ElasticSearch and also notify the engineers for specific security events
- Collect any malicious activities from GuardDuty to ElasticSearch and notify the engineers for critical events
- Collect load balancer and cloudfront logs from S3 to ElasticSearch

## Automate CloudFormation Ingestion Amazon Managed Services with Jenkins

![Alt text](./images/aws-ms-jenkins.drawio.svg?raw=true "Cfn Ingestion")
Engineers push changes to gitlab, then gitlab will trigger jenkins pipeline, in jenkins pipeline will send the cloudformation template to s3 then generate it's presign url then calling AMS api to ingest the cloudformation template and deploy it
