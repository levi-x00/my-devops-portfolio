from flask import Flask, render_template
import requests
import os

app = Flask(__name__)
SERVICE1_URL = os.environ['SERVICE1_URL']
SERVICE2_URL = os.environ['SERVICE2_URL']

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/get-service1-data', methods=['GET'])
def get_service1_data():
    try:
        # Call the /service-1 endpoint on the other service running on port 5001
        # update the url with ecs service discovery
        response = requests.get(SERVICE1_URL)
        return response.text
    except requests.exceptions.RequestException as e:
        return f"Error: {e}"
    
@app.route('/get-service2-data', methods=['GET'])
def get_service2_data():
    try:
        # Call the /service-2 endpoint on the other service running on port 5002
        # update the url with ecs service discovery
        response = requests.get(SERVICE2_URL)
        return response.text
    except requests.exceptions.RequestException as e:
        return f"Error: {e}"
    
@app.route('/health', methods=['GET'])
def health_check():
    return "OK"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
