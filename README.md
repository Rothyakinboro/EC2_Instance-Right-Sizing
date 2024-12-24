# Cost Optimization: EC2 Right-Sizing

## Introduction

Cost optimization is a critical strategy in cloud service management that DevOps Engineers, Cloud Architects, and other cloud specialists should adopt. It involves tracking unused resources, over-provisioned services, or unsuitable configurations for specific use cases. Mastering cost optimization not only reduces expenses but also improves resource efficiency and operational performance.

## Purpose
This project leverages CloudWatch and Lambda to periodically scan all EC2 instances, identify servers utilizing less than 20% of CPU, right-size them to smaller instances, and notify SMEs.

![image](https://github.com/user-attachments/assets/faf96754-382e-4976-aced-53586fc977ec)


## Project Scope

- Set up an EventBridge Scheduler to trigger the Lambda function.
- Implement the core logic using a Python Lambda function with Boto3.
- Scan EC2 instances with less than 20% CPU utilization and downgrade them to smaller machine types.
- Filter target instances to lower environments (e.g., Dev, Test), as right-sizing requires restarting EC2 instances and is unsuitable for production.
- Configure an SNS topic to notify users and SMEs of changes.

