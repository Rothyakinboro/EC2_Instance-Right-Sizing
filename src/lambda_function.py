import boto3
import datetime
import os

#sns_topic_arn = 'arn:aws:sns:ca-central-1:****:****'
sns_topic_arn = os.environ['SNS_TOPIC_ARN']  # Fetch SNS ARN from environment variable

def lambda_handler(event, context):
    cloudwatch = boto3.client('cloudwatch')
    ec2 = boto3.client('ec2')
    sns = boto3.client('sns')

    # Get all running EC2 instances
    instances = ec2.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
    
    recommendations = []
    resized_instances = []  # Track resizing details
    utilization_ok = []  # Track instances with adequate utilization
    now = datetime.datetime.utcnow()
    start_time = now - datetime.timedelta(days=7)  # Analyze metrics for the last 7 days

    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']

            # Check instance tags for 'Dev' or 'Test'
            tags = instance.get('Tags', [])
            tag_values = {tag['Key']: tag['Value'] for tag in tags}
            if tag_values.get('Environment') not in ['Dev', 'Test']:
                continue  # Skip instances without the desired tags

            # Query CloudWatch for CPUUtilization metrics
            response = cloudwatch.get_metric_statistics(
                Namespace='AWS/EC2',
                MetricName='CPUUtilization',
                Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
                StartTime=start_time,
                EndTime=now,
                Period=3600,
                Statistics=['Average'],
            )
            
            # Calculate average CPU utilization
            data_points = response.get('Datapoints', [])
            if data_points:
                avg_cpu = sum(dp['Average'] for dp in data_points) / len(data_points)
                
                # If average CPU utilization is below 20%, flag for resizing
                if avg_cpu < 20:
                    recommendations.append({
                        'InstanceId': instance_id,
                        'InstanceType': instance['InstanceType'],
                        'AvgCPUUtilization': avg_cpu,
                        'Recommendation': 'Consider downsizing'
                    })
                else:
                    utilization_ok.append({
                        'InstanceId': instance_id,
                        'InstanceType': instance['InstanceType'],
                        'AvgCPUUtilization': avg_cpu,
                        'Status': 'Utilization adequate'
                    })

    # Perform resizing for underutilized instances
    resize_map = {
        't2.medium': 't2.small',
        't2.small': 't2.micro'
    }

    for rec in recommendations:
        instance_id = rec['InstanceId']
        current_type = rec['InstanceType']
        
        if current_type in resize_map:
            new_type = resize_map[current_type]
            resized_type = resize_instance(instance_id, new_type)
            resized_instances.append({
                'InstanceId': instance_id,
                'OldType': current_type,
                'NewType': resized_type
            })
            # Send SNS notification for resizing
            sns.publish(
                TopicArn=sns_topic_arn,
                Subject="EC2 Instance Resized",
                Message=f"Instance {instance_id} resized from {current_type} to {resized_type} due to low utilization."
            )

    # Notify for adequate utilization
    for instance in utilization_ok:
        sns.publish(
            TopicArn=sns_topic_arn,
            Subject="EC2 Utilization Status",
            Message=f"Instance {instance['InstanceId']} ({instance['InstanceType']}) has adequate utilization with an average CPU of {instance['AvgCPUUtilization']:.2f}%."
        )

    return {
        'statusCode': 200,
        'message': 'Resizing completed for underutilized instances',
        'recommendations': recommendations,
        'resized_instances': resized_instances,
        'utilization_ok': utilization_ok
    }

def resize_instance(instance_id, target_instance_type):
    ec2 = boto3.client('ec2')

    # Stop the instance
    ec2.stop_instances(InstanceIds=[instance_id])
    waiter = ec2.get_waiter('instance_stopped')
    waiter.wait(InstanceIds=[instance_id])
    
    # Change instance type
    ec2.modify_instance_attribute(InstanceId=instance_id, Attribute='instanceType', Value=target_instance_type)
    
    # Start the instance
    ec2.start_instances(InstanceIds=[instance_id])
    return target_instance_type
