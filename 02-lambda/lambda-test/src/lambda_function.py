import boto3
import botocore
from pythonping import ping

def lambda_handler(event, context):
   print(f'boto3 version: {boto3.__version__}')
   print(f'botocore version: {botocore.__version__}')

   print(ping('google.com', verbose=True, count=4))