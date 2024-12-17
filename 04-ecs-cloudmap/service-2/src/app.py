from flask import Flask

app = Flask(__name__)
# test
@app.route('/service-2', methods=['GET'])
def service_2():
    return "Hello, this is service-2"

@app.route('/health', methods=['GET'])
def health_check():
    return "OK"
# test
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5002)
