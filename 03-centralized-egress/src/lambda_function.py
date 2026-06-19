import requests

def lambda_handler(event, context):
   response = requests.get('https://api.github.com/') 
   # print request object 
   print(response.url) 
   # print status code 
   print(response.status_code)
