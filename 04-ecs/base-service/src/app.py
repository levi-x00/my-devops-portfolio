from flask import Flask, render_template
import requests
import os


app = Flask(__name__)
SERVICE1_URL = os.environ['SERVICE1_URL']
SERVICE2_URL = os.environ['SERVICE2_URL']

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/service-1', methods=['GET'])
def get_service1_data():
    try:
        # Ensure SERVICE1_URL is the correct ECS service discovery endpoint
        response = requests.get(SERVICE1_URL, timeout=5)
        response.raise_for_status()  # Raise an error for bad status codes
        return render_template('service1.html', data=response.text)  # Assuming you have a template to render
    except requests.exceptions.RequestException as e:
        return "Error occurred while fetching data from service-1", 500

@app.route('/service-2', methods=['GET'])
def get_service2_data():
    try:
        # Ensure SERVICE1_URL is the correct ECS service discovery endpoint
        response = requests.get(SERVICE2_URL, timeout=5)
        response.raise_for_status()  # Raise an error for bad status codes
        return render_template('service2.html', data=response.text)  # Assuming you have a template to render
    except requests.exceptions.RequestException as e:
        return "Error occurred while fetching data from service-2", 500

    
@app.route('/health', methods=['GET'])
def health_check():
    return "OK"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
