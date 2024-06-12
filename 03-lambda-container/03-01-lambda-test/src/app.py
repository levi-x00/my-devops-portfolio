import sys
# test
def handler(event, context):
    return 'Hello from AWS Lambda using Python' + sys.version + '!'