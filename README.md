## My DevOps Portfolio

This repo showcases of my research and development (RnD) and my experience working as Cloud/DevOps/Site Reliability Engineer and any related field while keeping all proprietary confidential. Some projects that I worked in the past. Feel free to use it and A little support goes a long way! If you’d like to help me keep creating, you can do so in

<a href="https://ko-fi.com/mrpahlevi"><img src="https://github.com/levi-x00/my-devops-portfolio/blob/master/images/ko-fi-supportme.png" alt="Alt Text" width="200"/></a>

### Network and Infrastructure Design

---

![Alt text](./images/vpc-arch.png?raw=true "Network Architecture")
Project Descriptions:

- The VPC has two public, private, and database subnets each for resiliency
- KMS to encrypt some resources (e.g EBS, EFS, Secrets Manager, Session Manager, etc)
- ACM for SSL termination in load balancer

Project Purposes:

- Demonstrate how to setup infrastructure with highly resilience
- Understanding how networking works in AWS
- Understanding how to use terraform for the setup

### ELK Stacks

---

![Alt text](./images/cwlogs-to-es.drawio.svg?raw=true "Centralize Logs in ElasticSearch")

Project purposes:

- Events, audit, application (info, error, audit), and anti virus logs collected to CloudWatch Logs then parsed using lambda function to ElasticSearch (Amazon OpenSearch)
- CloudTrail events collected to CloudWatch Logs then parsed to ElasticSearch and also notify the engineers for specific security events
- Collect any malicious activities from GuardDuty to ElasticSearch and notify the engineers for critical events
- Collect load balancer and cloudfront logs from S3 to ElasticSearch

### Automate CloudFormation Ingestion Amazon Managed Services with Jenkins

---

![Alt text](./images/aws-ms-jenkins.drawio.svg?raw=true "Cfn Ingestion")
Project Descriptions:

- Engineers push changes to gitlab, then gitlab will trigger jenkins pipeline, in jenkins pipeline will send the cloudformation template to s3 then generate it's url then calling AMS api to ingest the cloudformation template and deploy it
- The purpose of this project to automate the RFC CloudFormation ingestion creation when using Amazon Managed Service with jenkins, so the engineers only need to fill the full path of the cloudformation template in gitlab before running the jenkins pipeline

### Centralized VPC Endpoint

---

![Alt text](./images/centralized-vpce.drawio.svg?raw=true "Centralized VPC Endpoints")
Project description & purposes:

- To put all service endpoints in single VPC instead of setup the vpce in each spoke VPC
- Cost reduction vpce usage

### Centralized Egress

---

![Alt text](./images/centralized-egress.drawio.svg?raw=true "Centralized VPC Egress")
Project description & purposes:

- The resources in the spoke VPC will have internet access instead of setup NAT gateway
- Cost reduction for NAT gateway usage

<!-- ### CI/CD with CodePipeline to EKS

---

comming soon

### CI/CD with CodePipeline to ECS

---

comming soon -->
