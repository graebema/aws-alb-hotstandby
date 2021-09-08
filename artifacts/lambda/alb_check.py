import json
import re
import os
import boto3

# Lambda global variables
region = os.environ["AWS_REGION"]  # from Lambda default envs
alb_tg_arn = os.environ["ALB_TG_ARN"]
alb_tg_hotstandby_arn = os.environ["ALB_TG_HOTSTANDBY_ARN"]
listener_arn = os.environ["ALB_LISTENER443_ARN"]

# check alb health and switch to other instance
def lambda_handler(event, context):

    # check default health
    health_default=get_tg_health(alb_tg_arn)
    print('default tg health=' + health_default)
    health_standby=get_tg_health(alb_tg_hotstandby_arn)
    print('standby tg health=' + health_standby)

    # check health values: healthy, unused
    if (health_default == 'healthy'):
        # healthy
        response='nothing todo default tg in use and healthy'
    elif(health_default == 'unused'):
        # assign default tg to alb
        response=assign_tg(listener_arn,alb_tg_arn)
        #print('need to assign default to ALB')
    elif (health_standby == 'unused'):
        # assign standy to ALB
        response=assign_tg(listener_arn,alb_tg_hotstandby_arn)
        #print('need to assign standby to ALB')
    else:
        response='not healthy TG available'

    print('RETURN : ' + json.dumps(str(response))
    return {
        'statusCode': 200,
        'body': json.dumps(str(response))
    }

def assign_tg(listener_arn,tg_arn):
    client = boto3.client('elbv2')
    response = client.modify_listener(
        ListenerArn=listener_arn,
        DefaultActions=[
            {
                'Type': 'forward',
                'TargetGroupArn': tg_arn,
                'Order' : 1
            },
        ]
    )
    #print(response)
    return response


def get_tg_health(tg_arn):
    # get health status of targetgroup

    client = boto3.client('elbv2')
    #print('get health status of TG:' + tg_arn)
    response = client.describe_target_health(
        TargetGroupArn=tg_arn
    )

    #print(response)
    #instancelist = []
    for item in (response["TargetHealthDescriptions"]):
        instance = item["Target"]["Id"]
        health = item["TargetHealth"]["State"]
     #   print('INSTANCE=' + str(instance))
     #   print('HEALTH=' + str(health))
        # only 1 instance, skip rest
        return health
