from datetime import datetime

import boto3

glue = boto3.client('glue')


def handler(event, context):
    now = datetime.utcnow()

    for table_name in event['Tables']:
        table_descriptor = glue.get_table(DatabaseName=event['Database'], Name=table_name)

        storage_descriptor = table_descriptor['Table']['StorageDescriptor']
        storage_descriptor['Location'] = '{location}/{partition}' \
            .format(location=storage_descriptor['Location'],
                    partition=f'{now.year:04d}/{now.month:02d}/{now.day:02d}/{now.hour:02d}')

        glue.create_partition(
            DatabaseName=event['Database'], TableName=table_name,
            PartitionInput={
                'Values': [f'{now.year:04d}-{now.month:02d}-{now.day:02d} {now.hour:02d}:00:00.000'],
                'StorageDescriptor': storage_descriptor
            })
