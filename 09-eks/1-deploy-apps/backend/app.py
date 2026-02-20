from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor
import os
import boto3

app = Flask(__name__)
CORS(app)

S3_BUCKET = os.getenv('S3_BUCKET')
AWS_REGION = os.getenv('AWS_REGION')
AWS_PROFILE = os.getenv('AWS_PROFILE')

def get_s3_client():
    if AWS_PROFILE:
        session = boto3.Session(profile_name=AWS_PROFILE, region_name=AWS_REGION)
    else:
        session = boto3.Session(region_name=AWS_REGION)
    return session.client('s3')

def get_db_connection():
    conn = psycopg2.connect(
        host=os.getenv('DB_HOST'),
        database=os.getenv('DB_NAME', 'postgres'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD')
    )
    return conn

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/health/ready', methods=['GET'])
def readiness():
    try:
        conn = get_db_connection()
        conn.close()
        return jsonify({'status': 'ready'}), 200
    except Exception as e:
        return jsonify({'status': 'not ready', 'error': str(e)}), 503

def generate_presigned_url(s3_url):
    if not s3_url or not S3_BUCKET:
        return s3_url
    key = s3_url.split(f"{S3_BUCKET}.s3.{AWS_REGION}.amazonaws.com/")[-1]
    return get_s3_client().generate_presigned_url(
        'get_object', Params={'Bucket': S3_BUCKET, 'Key': key}, ExpiresIn=3600
    )

@app.route('/api/items', methods=['GET'])
def get_items():
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute('SELECT * FROM items ORDER BY id')
    items = cur.fetchall()
    cur.close()
    conn.close()
    for item in items:
        item['image_url'] = generate_presigned_url(item['image_url'])
    return jsonify(items)

@app.route('/api/items/<int:id>', methods=['GET'])
def get_item(id):
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute('SELECT * FROM items WHERE id = %s', (id,))
    item = cur.fetchone()
    cur.close()
    conn.close()
    if item is None:
        return jsonify({'error': 'Item not found'}), 404
    item['image_url'] = generate_presigned_url(item['image_url'])
    return jsonify(item)

@app.route('/api/upload', methods=['POST'])
def upload_image():
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    file = request.files['file']
    key = f"items/{os.urandom(8).hex()}_{file.filename}"
    get_s3_client().upload_fileobj(file, S3_BUCKET, key, ExtraArgs={'ContentType': file.content_type})
    url = f"https://{S3_BUCKET}.s3.{AWS_REGION}.amazonaws.com/{key}"
    return jsonify({'url': url}), 200

@app.route('/api/items', methods=['POST'])
def create_item():
    data = request.get_json()
    name = data.get('name')
    description = data.get('description')
    image_url = data.get('image_url')
    
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute('INSERT INTO items (name, description, image_url) VALUES (%s, %s, %s) RETURNING *',
                (name, description, image_url))
    item = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    return jsonify(item), 201

@app.route('/api/items/<int:id>', methods=['PUT'])
def update_item(id):
    data = request.get_json()
    name = data.get('name')
    description = data.get('description')
    
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute('UPDATE items SET name = %s, description = %s WHERE id = %s RETURNING *',
                (name, description, id))
    item = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    if item is None:
        return jsonify({'error': 'Item not found'}), 404
    return jsonify(item)

@app.route('/api/items/<int:id>', methods=['DELETE'])
def delete_item(id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('DELETE FROM items WHERE id = %s', (id,))
    conn.commit()
    cur.close()
    conn.close()
    return '', 204

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
