from __future__ import print_function
from crhelper import CfnResource
import logging
import boto3
import os

logger = logging.getLogger(__name__)
helper = CfnResource(json_logging=False, log_level='DEBUG', boto_level='CRITICAL', sleep_on_delete=120, ssl_verify=None)
INSTACE_ID = os.environ['INSTACE_ID']
ASSISTANT_ARN = os.environ['ASSISTANT_ARN']
WISDOM_ARN = os.environ['WISDOM_ARN']

try:
    connect = boto3.client('connect')
    pass
except Exception as e:
    helper.init_failure(e)


@helper.create
def create(event, context):
    logger.info("Got Create")
    try:
        response = connect.create_integration_association(
            InstanceId=INSTACE_ID,
            IntegrationType='WISDOM_ASSISTANT',
            IntegrationArn=ASSISTANT_ARN
        )
        logger.info("Created Wisdom Assistant Association")
        logger.info(response)
        response = connect.create_integration_association(
            InstanceId=INSTACE_ID,
            IntegrationType='WISDOM_KNOWLEDGE_BASE',
            IntegrationArn=WISDOM_ARN
        )
        logger.info("Created Wisdom KB Association")
        logger.info(response)


    except Exception as e:
        print (e)
    else:
        return response

    
    helper.Data.update({"test": "testdata"})

    if not helper.Data.get("test"):
        raise ValueError("this error will show in the cloudformation events log and console.")
    
    return "MyResourceId"


@helper.update
def update(event, context):
    logger.info("Got Update")



@helper.delete
def delete(event, context):
    logger.info("Got Delete")



@helper.poll_create
def poll_create(event, context):
    logger.info("Got create poll")

    return True


def lambda_handler(event, context):
    helper(event, context)