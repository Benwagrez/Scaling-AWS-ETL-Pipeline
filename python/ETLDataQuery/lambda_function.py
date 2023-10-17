import boto3
import json
import os

etllambda						 = os.environ["etllambda"]		
prodclients					 = os.environ["prodclients"]
region               = os.environ["region"]
DataOutputBucketName = os.environ["DataOutputBucketName"]
cronjobcadence       = os.environ["cronjobcadence"] # how often a cron job it run, to pull from previous pull
deployvm             = os.environ["deployvm"]
deploylambda         = os.environ["deploylambda"]
deploycontainer      = os.environ["deploycontainer"]
output               ='s3://'+DataOutputBucketName+'/dataquery/'# Where API query results will be stored

def lambda_handler(event, context):
	if deployvm == "true":
		ec2idgrab = boto3.resource('ec2', region_name=region)
		ec2 = boto3.client('ec2', region_name=region)
		filters = [
			{
				'Name': 'tag:Group',
				'Values': ['autoexecutedaily']
			},
			{
				'Name': 'instance-state-name',
				'Values': ['stopped']
			}
		]

		instances = ec2idgrab.instances.filter(Filters=filters)

		ListOfInstances = [instance.id for instance in instances]

		if len(ListOfInstances) > 0:
			print("found instances with tag")
			print(ListOfInstances)
			response = ec2.start_instances(InstanceIds=ListOfInstances)
		else:
			print("none found")
			response = {
				'statusCode': 404,
				'body': json.dumps("404 Not Found: No eligible instances detected. The instance must be stopped and have a tag of type 'Group' with a value of 'autoexecutedaily'")
			}

		return response
	elif deploylambda == "true":
		invokelambda = boto3.client('lambda')
		for x in prodclients:
				payload = {"client":x.Name,"gitstring":x.GitConnectionString}
				response = invokelambda.invoke(
						FunctionName		= etllambda,
						InvocationType	= "Event",
						Payload					= bytes(json.dumps(payload), "utf-8")
				)
				print(json.loads(response['Payload'].read()))
				print("\n")
		
		response = {
			'statusCode': 200,
			'body': json.dumps("200 SUCCESS")
		}
		return response
	elif deploycontainer == "true":
		response=1
		return response
	else:
		return {
				'statusCode': 404,
				'body': json.dumps("404 Not Found: No deployment type detected")
		}
	
	return
