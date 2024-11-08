from flask import Flask

app = Flask(__name__)

@app.route('/service-1', methods=['GET'])
def service_1():
    return "Hello, this is service-1"

@app.route('/health', methods=['GET'])
def health_check():
    return "OK"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5001)
