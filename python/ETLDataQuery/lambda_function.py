import boto3
import json
import os

job_queue_arn				 = os.environ["job_queue_arn"]		
job_definition_arn   = os.environ["job_definition_arn"]		
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
		ec2foo = boto3.resource('ec2', region_name=region)
		invokeec2 = boto3.client('ec2', region_name=region)
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

		instances = ec2foo.instances.filter(Filters=filters)

		ListOfInstances = [instance.id for instance in instances]

		if len(ListOfInstances) > 0:
			print("found instances with tag")
			print(ListOfInstances)
			response = invokeec2.start_instances(InstanceIds=ListOfInstances)
		else:
			print("none found")
			response = {
				'statusCode': 404,
				'body': json.dumps("404 Not Found: No eligible instances detected. The instance must be stopped and have a tag of type 'Group' with a value of 'autoexecutedaily'")
			}

		return response
	elif deploylambda == "true":
		invokelambda = boto3.client('lambda', region_name=region)
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
		invokebatch = boto3.client('batch', region_name=region)
		
		job_name = "data-proc-job"
		job_queue = os.environ.get("job_queue")
		job_definition = os.environ.get("job_definition")
		print("Submitting job named '{job_name}' to queue '{job_queue}' with definition '{job_definition}'")
		response = invokebatch.submit_job(
			jobName=job_name,
			jobQueue=job_queue,
			jobDefinition=job_definition,
		)
		print("Submission successful, job ID: {response['jobId']}")
		response = {
			'statusCode': 200,
			'body': json.dumps("200 SUCCESS")
		}
		return response
	else:
		return {
				'statusCode': 404,
				'body': json.dumps("404 Not Found: No deployment type detected")
		}
	
	return
