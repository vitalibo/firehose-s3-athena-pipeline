# Kinesis Firehose + S3 + Athena

The simple solution that resolves problem adding new partitions created by Kinesis Firehose into Amazon Athena and allows creating data delivery pipelines.

![Diagram](https://www.lucidchart.com/publicSegments/view/f089e5d7-1605-465f-a058-342ad6d3448e/image.png)

1. Kinesis Firehose save data in S3 partitions with pattern `prefix/year/month/day/hour/`.
2. Amazon CloudWatch every hour trigger AWS Lambda, which in turn adds current partition (based on UTC time) into AWS Glue data catalog.

### Usage

First of all, you need setup AWS Glue partitioner AWS Lambda function, for this please run this command:

```bash
./update-stack.sh <name> <bucket> <profile>
```

To use AWS Glue partitioned AWS Lambda you need to create Amazon CloudWatch Event with JSON input string.  
Accordingly with specification JSON string must be contain `Database` and list of `Tables`.

```yaml
Cron:
  Type: 'AWS::Events::Rule'
  Properties:
    ScheduleExpression: cron(1 * * * ? *)
    State: ENABLED
    Targets:
      - Input: !Sub '{ "Database": "sample", "Tables": [ "foo", "bar", "baz" ] }'
        Arn: !GetAtt 
          - Lambda
          - Arn
        Id: TargetFunction
```

also, add permission to execute this lambda

```yaml
Permission:
  Type: 'AWS::Lambda::Permission'
  Properties:
    Action: 'lambda:InvokeFunction'
    FunctionName: !GetAtt 
      - Lambda
      - Arn
    Principal: events.amazonaws.com
    SourceArn: !GetAtt 
      - Cron
      - Arn
```
